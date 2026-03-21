import 'dart:async';

import 'package:flutter/material.dart';
import '../routes/application_api.dart';
import '../routes/white_fade.dart';

class HomeMenuPage extends StatefulWidget {
  const HomeMenuPage({super.key});

  @override
  State<HomeMenuPage> createState() => _HomeMenuPageState();
}

class _HomeMenuPageState extends State<HomeMenuPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;

  final List<DiscordMessage> _logs = [];
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

  Timer? _pollingTimer;

  static const String _baseUrl =
      'https://goddessutarea-production.up.railway.app';
  static const String _apiKey = 'API_TEST';

  @override
  void initState() {
    super.initState();

    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        await _fade.reverse().timeout(const Duration(milliseconds: 300));
      } catch (_) {}

      if (!mounted) return;

      await _refreshMessages(scrollToBottom: true);
      _startPolling();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _fade.dispose();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      await _refreshMessages();
    });
  }

  Future<void> _refreshMessages({bool scrollToBottom = false}) async {
    try {
      final messages = await fetchDiscordMessages(
        baseUrl: _baseUrl,
        apiKey: _apiKey,
      );

      if (!mounted) return;

      final oldLength = _logs.length;
      final changed = _hasMessageChanged(messages);

      if (!changed) return;

      setState(() {
        _logs
          ..clear()
          ..addAll(messages);
      });

      if (scrollToBottom || messages.length > oldLength) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.animateTo(
              _scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('fetchDiscordMessages error: $e');
    }
  }

  bool _hasMessageChanged(List<DiscordMessage> newMessages) {
    if (_logs.length != newMessages.length) return true;

    for (int i = 0; i < _logs.length; i++) {
      if (_logs[i].user != newMessages[i].user ||
          _logs[i].content != newMessages[i].content ||
          _logs[i].time != newMessages[i].time) {
        return true;
      }
    }

    return false;
  }

  Future<void> _sendMessage() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    _textCtrl.clear();
    setState(() {});

    try {
      await sendDiscordMessage(
        baseUrl: _baseUrl,
        apiKey: _apiKey,
        message: text,
      );
      await _refreshMessages(scrollToBottom: true);
    } catch (e) {
      debugPrint('sendDiscordMessage error: $e');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('送信に失敗しました: $e')),
      );
    }

    if (mounted) {
      _focusNode.requestFocus();
    }
  }

  void _openImageDialog(String assetPath) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: GestureDetector(
            onTap: () => Navigator.of(dialogContext).pop(),
            child: InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openImageDialog('assets/images/dialog.png'),
            child: Image.asset(
              'assets/images/main.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 32, 8, 110),
              child: ListView.builder(
                controller: _scrollCtrl,
                itemCount: _logs.length,
                itemBuilder: (_, index) {
                  final msg = _logs[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${msg.user}  ${_formatTime(msg.time.toLocal())}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg.content,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            left: 8,
            right: 8,
            bottom: 20,
            child: SafeArea(
              top: false,
              child: Material(
                color: Colors.transparent,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _textCtrl,
                        textInputAction: TextInputAction.send,
                        decoration: const InputDecoration(
                          hintText: 'メッセージを入力',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send),
                      color: const Color(0xFFFF64AA),
                    ),
                  ],
                ),
              ),
            ),
          ),

          WhiteFadeOverlay(
            animation: _fade,
            curve: Curves.easeOut,
          ),
        ],
      ),
    );
  }
}