// paper_surface.dart

import 'dart:math';
import 'package:flutter/material.dart';

class PaperSurface extends StatelessWidget {
  final Color color;
  final Widget child;

  const PaperSurface({super.key, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipPath(
        clipper: PaperEdgeClipper(),
        child: ColoredBox(
          color: color,
          child: CustomPaint(painter: PaperTexturePainter(), child: child),
        ),
      ),
    );
  }
}

class PaperEdgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height * 0.012);
    path.lineTo(size.width * 0.012, 0);
    path.lineTo(size.width * 0.968, 0);
    path.lineTo(size.width, size.height * 0.018);
    path.lineTo(size.width * 0.994, size.height * 0.965);
    path.lineTo(size.width * 0.978, size.height);
    path.lineTo(size.width * 0.024, size.height * 0.996);
    path.lineTo(size.width * 0.006, size.height * 0.978);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant PaperEdgeClipper oldClipper) {
    return false;
  }
}

class PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);

    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.035)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 900; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 0.55 + 0.15;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PaperTexturePainter oldDelegate) {
    return false;
  }
}
