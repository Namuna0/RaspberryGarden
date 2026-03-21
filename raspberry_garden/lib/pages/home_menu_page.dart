import 'package:flutter/material.dart';
import '../controllers/home_menu_controller.dart';
import '../routes/white_fade.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_list.dart';

class HomeMenuPage extends StatefulWidget {
  const HomeMenuPage({super.key});

  @override
  State<HomeMenuPage> createState() => _HomeMenuPageState();
}

class _HomeMenuPageState extends State<HomeMenuPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;
  late final HomeMenuController _controller;

  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

  static const String _baseUrl = 'https://goddessutarea-production.up.railway.app';
  static const String _apiKey = 'API_TEST';

  @override
  void initState() {
    super.initState();

    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );

    _controller = HomeMenuController(
      baseUrl: _baseUrl,
      apiKey: _apiKey,
    );

    _controller.addListener(_onMessagesUpdated);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        await _fade.reverse().timeout(const Duration(milliseconds: 300));
      } catch (_) {}

      if (!mounted) return;

      await _controller.initialize();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onMessagesUpdated);
    _controller.dispose();
    _fade.dispose();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onMessagesUpdated() {
    if (!mounted) return;

    setState(() {});

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

  Future<void> _sendMessage() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    _textCtrl.clear();
    setState(() {});

    try {
      await _controller.sendMessage(text);
    } catch (e) {
      debugPrint('sendMessage error: $e');

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

  @override
  Widget build(BuildContext context) {
    final messages = _controller.messages;

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
              child: ChatMessageList(
                messages: messages,
                scrollController: _scrollCtrl,
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
                child: ChatInputBar(
                  controller: _textCtrl,
                  focusNode: _focusNode,
                  onSend: _sendMessage,
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