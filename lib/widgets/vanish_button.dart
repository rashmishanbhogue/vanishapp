// vanish_button.dart

import 'package:flutter/material.dart';

class VanishButton extends StatelessWidget {
  final String phrase;
  final bool enabled;
  final VoidCallback onPressed;

  const VanishButton({
    super.key,
    required this.phrase,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0x12000000),
        foregroundColor: const Color(0x73000000),
        disabledBackgroundColor: const Color(0x08000000),
        disabledForegroundColor: const Color(0x38000000),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        shape: const StadiumBorder(),
      ),
      child: Text(
        phrase,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
