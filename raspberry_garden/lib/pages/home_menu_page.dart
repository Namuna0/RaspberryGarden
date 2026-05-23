import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../controllers/home_menu_controller.dart';
import '../routes/white_fade.dart';
import '../services/app_user_service.dart';
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
  HomeMenuController? _controller;

  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();

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
        await _fade.reverse().timeout(const Duration(milliseconds: 500));
      } catch (_) {}

      if (!mounted) return;

      final appUserId = await AppUserService.getOrCreateAppUserId();

      final controller = HomeMenuController(
        baseUrl: AppConfig.baseUrl,
        apiKey: AppConfig.apiKey,
        appUserId: appUserId,
      );

      controller.addListener(_onMessagesUpdated);

      setState(() {
        _controller = controller;
      });

      await controller.initialize();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller?.removeListener(_onMessagesUpdated);
    _controller?.dispose();
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
    final controller = _controller;
    if (controller == null) return;

    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    _textCtrl.clear();

    try {
      await controller.sendMessage(text);
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
    final controller = _controller;

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
          if (controller != null && controller.channelName.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              right: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.70),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.channelName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 58),
              child: controller == null
                  ? const SizedBox.shrink()
                  : ChatMessageList(
                      messages: controller.messages,
                      scrollController: _scrollCtrl,
                      isMyMessage: controller.isMyMessage,
                    ),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 8,
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
