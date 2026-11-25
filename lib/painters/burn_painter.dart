// burn_painter.dart

import 'dart:math';
import 'package:flutter/material.dart';

class BurnPainter extends CustomPainter {
  final double progress;

  BurnPainter({required this.progress});

  double get burnProgress => Curves.easeIn.transform(progress.clamp(0.0, 1.0));

  double edgeY(double x, Size size) {
    final normalizedX = x / size.width;

    return size.height * (1 - burnProgress) +
        sin(normalizedX * 31 + progress * 15) * size.height * 0.018 +
        sin(normalizedX * 67 + progress * 21) * size.height * 0.009;
  }

  Path createEdge(Size size) {
    final path = Path();

    for (int i = 0; i <= 100; i++) {
      final x = size.width * i / 100;
      final y = edgeY(x, size);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final edge = createEdge(size);

    final glowPaint = Paint()
      ..color = const Color(
        0xFFFF5700,
      ).withValues(alpha: 0.45 * (1 - progress * 0.4))
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final orangePaint = Paint()
      ..color = const Color(0xFFFF7900)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final yellowPaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final charPaint = Paint()
      ..color = const Color(0xFF292019)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(edge, glowPaint);
    canvas.drawPath(edge, orangePaint);
    canvas.drawPath(edge, yellowPaint);
    canvas.drawPath(edge, charPaint);

    // Small irregular embers around the advancing edge.
    final random = Random(19);

    for (int i = 0; i < 42; i++) {
      final x = random.nextDouble() * size.width;
      final y = edgeY(x, size) - random.nextDouble() * 45;

      if (y < 0 || y > size.height) continue;

      final emberPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFFFFD54F),
          const Color(0xFFFF3D00),
          random.nextDouble(),
        )!.withValues(alpha: 0.85 * (1 - progress * 0.5));

      canvas.drawCircle(
        Offset(x, y),
        random.nextDouble() * 2 + 0.5,
        emberPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BurnPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
