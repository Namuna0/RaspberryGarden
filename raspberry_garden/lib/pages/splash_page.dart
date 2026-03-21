import 'package:flutter/material.dart';
import '../routes/white_fade.dart';
import 'home_menu_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;
  bool _tapped = false;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    if (_tapped) return;
    _tapped = true;

    await whiteFadeReplace(
      context: context,
      controller: _fade,
      nextPage: const HomeMenuPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goNext,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/title.png', fit: BoxFit.cover),
            WhiteFadeOverlay(animation: _fade, curve: Curves.easeIn),
          ],
        ),
      ),
    );
  }
}
