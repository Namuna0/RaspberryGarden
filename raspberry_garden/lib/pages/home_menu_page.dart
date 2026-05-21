import 'package:flutter/material.dart';
import '../controllers/home_menu_controller.dart';
import '../routes/white_fade.dart';
import '../services/app_user_service.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_list.dart';
import 'database_searcher.dart';

class HomeMenuPage extends StatefulWidget {
  const HomeMenuPage({super.key});

  @override
  State<HomeMenuPage> createState() => _HomeMenuPageState();
}

class _HomeMenuPageState extends State<HomeMenuPage>
    with TickerProviderStateMixin {
  late final AnimationController _fade;
  late final AnimationController _menuAnim;
  HomeMenuController? _controller;

  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();

  static const String _baseUrl = 'https://goddessutarea-production.up.railway.app';
  static const String _apiKey = 'API_TEST';
  static const double _menuWidth = 220;
  static const double _edgeThreshold = 40;

  @override
  void initState() {
    super.initState();

    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
    _menuAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      try {
        await _fade.reverse().timeout(const Duration(milliseconds: 500));
      } catch (_) {}

      if (!mounted) return;

      final appUserId = await AppUserService.getOrCreateAppUserId();

      final controller = HomeMenuController(
        baseUrl: _baseUrl,
        apiKey: _apiKey,
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
    _menuAnim.dispose();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openMenu() => _menuAnim.forward();

  void _closeMenu() => _menuAnim.reverse();

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
    setState(() {});

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
      resizeToAvoidBottomInset: true,
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
          // 右端スワイプ検知
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: _edgeThreshold,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (d) {
                if (d.delta.dx < -2) _openMenu();
              },
            ),
          ),
          // オーバーレイ背景 + メニューパネル
          AnimatedBuilder(
            animation: _menuAnim,
            builder: (_, __) {
              if (_menuAnim.value == 0) return const SizedBox.shrink();
              final slide = CurvedAnimation(
                parent: _menuAnim,
                curve: Curves.easeOut,
              );
              return Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: _closeMenu,
                    child: Container(
                      color: Colors.black.withOpacity(0.4 * _menuAnim.value),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: _menuWidth * (slide.value - 1),
                    width: _menuWidth,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (d) {
                        if (d.delta.dx > 2) _closeMenu();
                      },
                      child: Container(
                        color: Colors.black.withOpacity(0.85),
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 16,
                          bottom: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                'メニュー',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Divider(color: Colors.white24),
                            _MenuItem(
                              icon: Icons.chat_bubble_outline,
                              label: 'チャット',
                              onTap: _closeMenu,
                            ),
                            _MenuItem(
                              icon: Icons.search,
                              label: '予想検索',
                              onTap: () async {
                                _closeMenu();
                                await Future.delayed(
                                    const Duration(milliseconds: 200));
                                if (!context.mounted) return;
                                await whiteFadeReplace(
                                  context: context,
                                  controller: _fade,
                                  nextPage: const DatabaseSearcher(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
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

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
