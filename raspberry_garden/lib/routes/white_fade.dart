import 'package:flutter/material.dart';

class WhiteFadeOverlay extends StatelessWidget {
  const WhiteFadeOverlay({
    super.key,
    required this.animation,
    this.curve = Curves.easeInOut,
  });

  final Animation<double> animation;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: curve);

    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: curved,
        builder: (_, __) => Container(
          color: Colors.white.withOpacity(curved.value),
        ),
      ),
    );
  }
}

Future<void> whiteFadeReplace({
  required BuildContext context,
  required AnimationController controller,
  required Widget nextPage,
}) async {
  await controller.forward();
  if (!context.mounted) return;

  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      transitionDuration: Duration.zero,
      pageBuilder: (_, __, ___) => nextPage,
    ),
  );
}
