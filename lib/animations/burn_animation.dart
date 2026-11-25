// burn_animation.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../painters/burn_painter.dart';

class BurnAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onCompleted;

  const BurnAnimation({super.key, required this.child, this.onCompleted});

  @override
  State<BurnAnimation> createState() => BurnAnimationState();
}

class BurnAnimationState extends State<BurnAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    controller.forward().whenComplete(() {
      if (mounted) widget.onCompleted?.call();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return ClipPath(
          clipper: BurnPaperClipper(progress: controller.value),
          child: Stack(
            children: [
              widget.child,
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: BurnPainter(progress: controller.value),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BurnPaperClipper extends CustomClipper<Path> {
  final double progress;

  BurnPaperClipper({required this.progress});

  @override
  Path getClip(Size size) {
    final path = Path();

    final burnProgress = Curves.easeIn.transform(progress);
    final baseY = size.height * (1 - burnProgress);

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, baseY);

    for (int i = 40; i >= 0; i--) {
      final x = size.width * i / 40;

      final wave = sin(i * 1.7 + progress * 15) * size.height * 0.018;
      final smallWave = sin(i * 3.1 + progress * 21) * size.height * 0.009;

      path.lineTo(x, baseY + wave + smallWave);
    }

    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant BurnPaperClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

class BurnEdgePainter extends CustomPainter {
  final double progress;

  BurnEdgePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.01) return;

    final burnProgress = Curves.easeIn.transform(progress);
    final baseY = size.height * (1 - burnProgress);

    final edge = Path();

    for (int i = 0; i <= 80; i++) {
      final x = size.width * i / 80;

      final wave = sin(i * 0.85 + progress * 15) * size.height * 0.018;
      final smallWave = sin(i * 2.1 + progress * 21) * size.height * 0.009;

      final y = baseY + wave + smallWave;

      if (i == 0) {
        edge.moveTo(x, y);
      } else {
        edge.lineTo(x, y);
      }
    }

    // Orange outer glow
    final glowPaint = Paint()
      ..color = const Color(
        0xFFFF6A00,
      ).withValues(alpha: 0.48 * (1 - progress * 0.4))
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // Bright orange burning rim
    final orangePaint = Paint()
      ..color = const Color(0xFFFF8C00).withValues(alpha: 0.95)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Hot yellow inner highlight
    final yellowPaint = Paint()
      ..color = const Color(0xFFFFD54F).withValues(alpha: 0.95)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Dark charred boundary
    final charPaint = Paint()
      ..color = const Color(0xFF292019)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(edge, glowPaint);
    canvas.drawPath(edge, orangePaint);
    canvas.drawPath(edge, yellowPaint);
    canvas.drawPath(edge, charPaint);

    // Ember particles
    final random = Random(19);

    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y =
          baseY +
          (random.nextDouble() - 0.5) * 20 -
          random.nextDouble() * progress * 45;

      if (y < 0 || y > size.height) continue;

      final emberPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFFFFB300),
          const Color(0xFFFF3D00),
          random.nextDouble(),
        )!.withValues(alpha: 0.9 * (1 - progress * 0.55));

      canvas.drawCircle(
        Offset(x, y),
        random.nextDouble() * 2.2 + 0.5,
        emberPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BurnEdgePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
