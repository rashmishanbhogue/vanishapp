// let_go_animation.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../painters/particle_painter.dart';

class LetGoAnimation extends StatefulWidget {
  final Widget child;
  final String text;
  final VoidCallback? onCompleted;

  const LetGoAnimation({
    super.key,
    required this.child,
    required this.text,
    this.onCompleted,
  });

  @override
  State<LetGoAnimation> createState() => LetGoAnimationState();
}

class LetGoAnimationState extends State<LetGoAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final List<FlyingGlyph> glyphs;

  @override
  void initState() {
    super.initState();

    glyphs = createGlyphs(widget.text);

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );

    controller.forward().whenComplete(() {
      if (mounted) widget.onCompleted?.call();
    });
  }

  List<FlyingGlyph> createGlyphs(String text) {
    final random = Random(42);
    final result = <FlyingGlyph>[];

    const startX = 20.0;
    const startY = 54.0;
    const availableWidth = 440.0;
    const lineHeight = 26.25;

    double x = startX;
    double y = startY;

    for (final character in text.characters) {
      if (character == '\n') {
        x = startX;
        y += lineHeight;
        continue;
      }

      final painter = TextPainter(
        text: TextSpan(
          text: character,
          style: const TextStyle(fontSize: 15, height: 1.75),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      if (x + painter.width > startX + availableWidth &&
          character.trim().isNotEmpty) {
        x = startX;
        y += lineHeight;
      }

      result.add(
        FlyingGlyph(
          character: character,
          position: Offset(x, y),
          width: painter.width,
          driftX: (random.nextDouble() - 0.4) * 110,
          driftY: -(random.nextDouble() * 130 + 35),
          rotation: (random.nextDouble() - 0.5) * 1.4,
          delay: random.nextDouble() * 0.3,
          size: 15,
        ),
      );

      x += painter.width;
    }

    return result;
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
        final progress = controller.value;

        final paperOpacity =
            (1 -
                    Curves.easeIn.transform(
                      ((progress - 0.55) / 0.45).clamp(0.0, 1.0),
                    ))
                .clamp(0.0, 1.0);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Opacity(
              opacity: paperOpacity,
              child: Transform.translate(
                offset: Offset(-5 * progress, -15 * progress),
                child: widget.child,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: ParticlePainter(progress: progress, glyphs: glyphs),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
