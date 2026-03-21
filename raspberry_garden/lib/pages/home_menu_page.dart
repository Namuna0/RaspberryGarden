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

  final List<String> _logs = [];
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

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
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _fade.dispose();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _logs.add(text);
      _textCtrl.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      await sendDiscordMessage(
        baseUrl: 'https://goddessutarea-production.up.railway.app',
        apiKey: 'API_TEST',
        message: text,
      );
    } catch (e) {
      debugPrint('sendDiscordMessage error: $e');
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
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _logs[index],
                      style: const TextStyle(color: Colors.white),
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
                      color: Colors.white,
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