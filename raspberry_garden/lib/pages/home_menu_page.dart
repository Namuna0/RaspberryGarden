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

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fade.reverse();
    });
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  void _openImageDialog(String assetPath) {
    sendDiscordMessage(
      baseUrl: 'https://goddessutarea-production.up.railway.app', // Railway の Public Domain
      apiKey: 'API_TEST',
    );

    showDialog(
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
                child: Image.asset(assetPath, fit: BoxFit.contain),
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openImageDialog('assets/images/dialog.png'),
            child: Image.asset('assets/images/main.png', fit: BoxFit.cover),
          ),

          WhiteFadeOverlay(animation: _fade, curve: Curves.easeOut),
        ],
      ),
    );
  }
}