import 'package:flutter/material.dart';
import 'database_searcher.dart';
import 'home_menu_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  static const double _menuWidth = 220;
  static const double _edgeThreshold = 40;

  late final AnimationController _menuAnim;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _menuAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _menuAnim.dispose();
    super.dispose();
  }

  void _openMenu() => _menuAnim.forward();

  void _closeMenu() => _menuAnim.reverse();

  void _switchPage(int index) {
    _closeMenu();
    setState(() => _pageIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          IndexedStack(
            index: _pageIndex,
            children: const [
              HomeMenuPage(),
              DatabaseSearcher(),
            ],
          ),
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
                              selected: _pageIndex == 0,
                              onTap: () => _switchPage(0),
                            ),
                            _MenuItem(
                              icon: Icons.search,
                              label: '予想検索',
                              selected: _pageIndex == 1,
                              onTap: () => _switchPage(1),
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
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? Colors.white.withOpacity(0.1) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? Colors.white : Colors.white70, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontSize: 15,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
