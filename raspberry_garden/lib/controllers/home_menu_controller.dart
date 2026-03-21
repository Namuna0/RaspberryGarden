import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/discord_message.dart';
import '../routes/application_api.dart';

class HomeMenuController extends ChangeNotifier {
  HomeMenuController({
    required this.baseUrl,
    required this.apiKey,
  });

  final String baseUrl;
  final String apiKey;

  final List<DiscordMessage> _messages = [];
  Timer? _pollingTimer;

  List<DiscordMessage> get messages => List.unmodifiable(_messages);

  Future<void> initialize() async {
    await refreshMessages();
    startPolling();
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
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
    );

    await refreshMessages();
  }

  bool _hasChanged(List<DiscordMessage> newMessages) {
    if (_messages.length != newMessages.length) return true;

    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].user != newMessages[i].user ||
          _messages[i].content != newMessages[i].content ||
          _messages[i].time != newMessages[i].time) {
        return true;
      }
    }

    return false;
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}