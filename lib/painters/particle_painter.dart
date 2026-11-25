// particle_painter.dart

import 'package:flutter/material.dart';

class FlyingGlyph {
  final String character;
  final Offset position;
  final double width;
  final double driftX;
  final double driftY;
  final double rotation;
  final double delay;
  final double size;

  const FlyingGlyph({
    required this.character,
    required this.position,
    required this.width,
    required this.driftX,
    required this.driftY,
    required this.rotation,
    required this.delay,
    required this.size,
  });
}

class ParticlePainter extends CustomPainter {
  final double progress;
  final List<FlyingGlyph> glyphs;

  ParticlePainter({required this.progress, required this.glyphs});

  @override
  void paint(Canvas canvas, Size size) {
    for (final glyph in glyphs) {
      final localProgress = ((progress - glyph.delay) / (1 - glyph.delay))
          .clamp(0.0, 1.0);

      if (progress < glyph.delay) continue;

      final t = Curves.easeOut.transform(localProgress);

      final position = Offset(
        glyph.position.dx + glyph.driftX * t,
        glyph.position.dy + glyph.driftY * t,
      );

      final opacity = (1 - localProgress).clamp(0.0, 1.0);

      final painter = TextPainter(
        text: TextSpan(
          text: glyph.character,
          style: TextStyle(
            fontSize: glyph.size * (1 - localProgress * 0.25),
            color: const Color(0xB8000000).withValues(alpha: opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(glyph.rotation * t);
      painter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.glyphs != glyphs;
  }
}
