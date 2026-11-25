// gone_animation.dart

import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GoneAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onCompleted;

  const GoneAnimation({super.key, required this.child, this.onCompleted});

  @override
  State<GoneAnimation> createState() => GoneAnimationState();
}

class GoneAnimationState extends State<GoneAnimation>
    with SingleTickerProviderStateMixin {
  final GlobalKey paperKey = GlobalKey();

  late final AnimationController controller;

  ui.Image? paperImage;
  Size paperSize = Size.zero;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      capturePaper();
    });
  }

  Future<void> capturePaper() async {
    if (!mounted) return;

    final boundary =
        paperKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null || !boundary.hasSize) return;

    try {
      final image = await boundary.toImage(pixelRatio: 1.5);

      if (!mounted) {
        image.dispose();
        return;
      }

      setState(() {
        paperImage = image;
        paperSize = Size(boundary.size.width, boundary.size.height);
      });

      controller.forward().whenComplete(() {
        if (mounted) widget.onCompleted?.call();
      });
    } catch (error) {
      debugPrint('Paper capture failed: $error');

      if (mounted) widget.onCompleted?.call();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    paperImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (paperImage == null) {
      return RepaintBoundary(key: paperKey, child: widget.child);
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          size: paperSize,
          painter: TornPaperPainter(
            image: paperImage!,
            progress: controller.value,
          ),
        );
      },
    );
  }
}

class TornPaperPainter extends CustomPainter {
  final ui.Image image;
  final double progress;

  TornPaperPainter({required this.image, required this.progress});

  double tearX(double y, Size size) {
    final normalized = y / size.height;

    return size.width *
        (0.5 +
            0.025 * sin(normalized * pi * 2.4) +
            0.014 * sin(normalized * pi * 8.5) +
            0.009 * cos(normalized * pi * 15));
  }

  Path makeHalfPath(Size size, bool left) {
    final path = Path();

    const segments = 140;

    if (left) {
      path.moveTo(0, 0);
      path.lineTo(tearX(0, size), 0);

      for (int i = 1; i <= segments; i++) {
        final y = size.height * i / segments;
        final roughness = sin(i * 2.8) * 1.8 + cos(i * 5.2) * 1.1;

        path.lineTo(tearX(y, size) + roughness, y);
      }

      path.lineTo(0, size.height);
    } else {
      path.moveTo(tearX(0, size), 0);

      for (int i = 1; i <= segments; i++) {
        final y = size.height * i / segments;
        final roughness = sin(i * 2.8) * 1.8 + cos(i * 5.2) * 1.1;

        path.lineTo(tearX(y, size) + roughness, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final tearProgress = Curves.easeInOutCubic.transform(
      (progress / 0.48).clamp(0.0, 1.0),
    );

    final separation = Curves.easeInCubic.transform(
      ((progress - 0.40) / 0.60).clamp(0.0, 1.0),
    );

    final opacity =
        (1 -
                Curves.easeIn.transform(
                  ((progress - 0.76) / 0.24).clamp(0.0, 1.0),
                ))
            .clamp(0.0, 1.0);

    final leftPath = makeHalfPath(size, true);
    final rightPath = makeHalfPath(size, false);

    final imagePaint = Paint()..filterQuality = FilterQuality.high;

    final source = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final destination = Offset.zero & size;

    canvas.saveLayer(
      Offset.zero & size,
      Paint()..color = Colors.white.withValues(alpha: opacity),
    );

    // Left half curls backwards and moves left.
    canvas.save();

    canvas.translate(-size.width * 0.85 * separation, -20 * separation);

    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.16 * separation);
    canvas.scale(1 - separation * 0.06);
    canvas.translate(-size.width / 2, -size.height / 2);

    canvas.clipPath(leftPath);

    canvas.drawImageRect(image, source, destination, imagePaint);

    canvas.restore();

    // Right half moves independently in the opposite direction.
    canvas.save();

    canvas.translate(size.width * 0.85 * separation, 25 * separation);

    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(0.19 * separation);
    canvas.scale(1 - separation * 0.04);
    canvas.translate(-size.width / 2, -size.height / 2);

    canvas.clipPath(rightPath);

    canvas.drawImageRect(image, source, destination, imagePaint);

    canvas.restore();

    // Advancing tear edge.
    if (tearProgress < 1 && separation < 0.4) {
      final tearPath = Path();

      final revealHeight = size.height * tearProgress;

      for (int i = 0; i <= 140; i++) {
        final y = revealHeight * i / 140;
        final x = tearX(y, size);

        if (i == 0) {
          tearPath.moveTo(x, y);
        } else {
          tearPath.lineTo(x, y);
        }
      }

      final shadowPaint = Paint()
        ..color = const Color(0xFF493D2D).withValues(alpha: 0.3)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final tornEdgePaint = Paint()
        ..color = const Color(0xFF8E7958)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;

      final highlightPaint = Paint()
        ..color = const Color(0xFFFFF8DC)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      canvas.drawPath(tearPath, shadowPaint);
      canvas.drawPath(tearPath, tornEdgePaint);

      canvas.save();
      canvas.translate(2, 0);
      canvas.drawPath(tearPath, highlightPaint);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TornPaperPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.image != image;
  }
}
