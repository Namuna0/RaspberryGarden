import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/discord_message.dart';
import '../routes/application_api.dart';

class HomeMenuController extends ChangeNotifier {
  HomeMenuController({
    required this.baseUrl,
    required this.apiKey,
    required this.appUserId,
  });

  final String baseUrl;
  final String apiKey;
  final String appUserId;

  final List<DiscordMessage> _messages = [];
  Timer? _pollingTimer;
  String channelName = '';

  List<DiscordMessage> get messages => List.unmodifiable(_messages);

  Future<void> initialize() async {
    await Future.wait([
      refreshMessages(),
      _fetchChannelName(),
    ]);
    startPolling();
  }

  Future<void> _fetchChannelName() async {
    try {
      channelName = await fetchChannelName(baseUrl: baseUrl, apiKey: apiKey);
      notifyListeners();
    } catch (e) {
      debugPrint('fetchChannelName error: $e');
    }
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await refreshMessages();
    });
  }

  Future<void> refreshMessages() async {
    try {
      final newMessages = await fetchDiscordMessages(
        baseUrl: baseUrl,
        apiKey: apiKey,
      );

      if (!_hasChanged(newMessages)) return;

      _messages
        ..clear()
        ..addAll(newMessages);

      notifyListeners();
    } catch (e) {
      debugPrint('refreshMessages error: $e');
    }
  }

  Future<void> sendMessage(String text) async {
    await sendDiscordMessage(
      baseUrl: baseUrl,
      apiKey: apiKey,
      message: text,
      appUserId: appUserId,
    );

    await refreshMessages();
  }

  bool _hasChanged(List<DiscordMessage> newMessages) {
    if (_messages.length != newMessages.length) return true;

    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].user != newMessages[i].user ||
          _messages[i].content != newMessages[i].content ||
          _messages[i].time != newMessages[i].time ||
          _messages[i].appUserId != newMessages[i].appUserId) {
        return true;
      }
    }

    return false;
  }

  bool isMyMessage(DiscordMessage message) {
    return message.appUserId != null && message.appUserId == appUserId;
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}