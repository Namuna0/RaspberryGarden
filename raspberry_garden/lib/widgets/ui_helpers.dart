import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> copyToClipboard(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('コピーしました'),
      duration: Duration(seconds: 1),
    ),
  );
}

BoxDecoration darkRoundedBox({double opacity = 0.70, double radius = 8}) {
  return BoxDecoration(
    color: Colors.black.withOpacity(opacity),
    borderRadius: BorderRadius.circular(radius),
  );
}
