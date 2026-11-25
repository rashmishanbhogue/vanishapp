// crumple_painter.dart

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class CrumplePainter extends CustomPainter {
  final ui.Image image;
  final double progress;

  CrumplePainter({required this.image, required this.progress});

  static const int columns = 22;
  static const int rows = 18;

  double smooth(double value) {
    return Curves.easeInOutCubic.transform(value.clamp(0.0, 1.0));
  }

  Offset targetPosition(int column, int row, Size size, double fold) {
    final nx = column / columns;
    final ny = row / rows;

    final dx = nx - 0.5;
    final dy = ny - 0.5;
    final angle = atan2(dy, dx);
    final distance = sqrt(dx * dx + dy * dy);

    final irregularity =
        1 +
        0.17 * sin(angle * 5 + 0.7) +
        0.10 * cos(angle * 8) +
        0.06 * sin(angle * 13);

    final radius = 58 * irregularity * distance / 0.707;

    final target = Offset(
      size.width / 2 + cos(angle) * radius,
      size.height / 2 + sin(angle) * radius * 0.82,
    );

    final creaseX = sin(nx * 31 + ny * 17) * 15 * fold;
    final creaseY = cos(nx * 23 - ny * 29) * 13 * fold;

    return Offset(
      nx * size.width * (1 - fold) + target.dx * fold + creaseX,
      ny * size.height * (1 - fold) + target.dy * fold + creaseY,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final fold = smooth(progress / 0.72);
    final flight = smooth((progress - 0.66) / 0.34);

    canvas.save();

    canvas.translate(size.width * 0.78 * flight, -size.height * 0.62 * flight);

    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(flight * 7 + fold * 1.4);
    canvas.scale(1 - flight * 0.18);
    canvas.translate(-size.width / 2, -size.height / 2);

    final positions = <Offset>[];
    final textureCoordinates = <Offset>[];
    final colors = <Color>[];

    final originalPoints = <Offset>[];
    final foldedPoints = <Offset>[];

    for (int row = 0; row <= rows; row++) {
      for (int column = 0; column <= columns; column++) {
        originalPoints.add(
          Offset(size.width * column / columns, size.height * row / rows),
        );

        foldedPoints.add(targetPosition(column, row, size, fold));
      }
    }

    Offset meshPoint(int column, int row) {
      final index = row * (columns + 1) + column;

      return Offset.lerp(originalPoints[index], foldedPoints[index], fold)!;
    }

    void addVertex(int column, int row) {
      positions.add(meshPoint(column, row));

      textureCoordinates.add(
        Offset(image.width * column / columns, image.height * row / rows),
      );

      final shade = (0.91 + 0.09 * sin(column * 1.7 + row * 2.3 + fold * 8))
          .clamp(0.0, 1.0);

      colors.add(
        Color.fromARGB(
          255,
          (255 * shade).round(),
          (255 * shade).round(),
          (255 * shade).round(),
        ),
      );
    }

    for (int row = 0; row < rows; row++) {
      for (int column = 0; column < columns; column++) {
        addVertex(column, row);
        addVertex(column + 1, row);
        addVertex(column, row + 1);

        addVertex(column + 1, row);
        addVertex(column + 1, row + 1);
        addVertex(column, row + 1);
      }
    }

    final vertices = ui.Vertices(
      ui.VertexMode.triangles,
      positions,
      textureCoordinates: textureCoordinates,
      colors: colors,
    );

    final shader = ui.ImageShader(
      image,
      TileMode.clamp,
      TileMode.clamp,
      Matrix4.identity().storage,
    );

    final paint = Paint()
      ..shader = shader
      ..filterQuality = FilterQuality.medium;

    canvas.drawVertices(vertices, BlendMode.modulate, paint);

    vertices.dispose();
    shader.dispose();

    if (fold > 0.45) {
      final shadowOpacity = ((fold - 0.45) / 0.55).clamp(0.0, 1.0) * 0.22;

      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: shadowOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2 + 45),
        48,
        shadowPaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CrumplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.image != image;
  }
}

class CrumpledBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.39;

    final outline = Path();

    for (int i = 0; i <= 72; i++) {
      final angle = 2 * pi * i / 72;

      final irregularity =
          1 +
          0.11 * sin(angle * 5 + 0.5) +
          0.065 * cos(angle * 9) +
          0.035 * sin(angle * 13);

      final point = Offset(
        center.dx + cos(angle) * radius * irregularity,
        center.dy + sin(angle) * radius * irregularity * 0.84,
      );

      if (i == 0) {
        outline.moveTo(point.dx, point.dy);
      } else {
        outline.lineTo(point.dx, point.dy);
      }
    }

    outline.close();

    canvas.drawShadow(outline, Colors.black38, 12, true);

    final paperPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.38, -0.5),
        radius: 0.95,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFFFF9D7),
          Color(0xFFE9DCA9),
          Color(0xFFB5A276),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(outline, paperPaint);

    canvas.save();
    canvas.clipPath(outline);

    final folds = [
      [Offset(0.08, 0.30), Offset(0.37, 0.38), Offset(0.72, 0.16)],
      [Offset(0.12, 0.72), Offset(0.43, 0.47), Offset(0.89, 0.66)],
      [Offset(0.29, 0.04), Offset(0.48, 0.52), Offset(0.64, 0.94)],
      [Offset(0.94, 0.33), Offset(0.54, 0.52), Offset(0.08, 0.79)],
      [Offset(0.13, 0.46), Offset(0.48, 0.17), Offset(0.88, 0.50)],
      [Offset(0.25, 0.15), Offset(0.58, 0.65), Offset(0.78, 0.87)],
      [Offset(0.08, 0.56), Offset(0.49, 0.72), Offset(0.87, 0.32)],
      [Offset(0.38, 0.08), Offset(0.28, 0.52), Offset(0.67, 0.82)],
    ];

    final shadowPaint = Paint()
      ..color = const Color(0xFF796744).withValues(alpha: 0.65)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < folds.length; i++) {
      final path = Path()
        ..moveTo(size.width * folds[i][0].dx, size.height * folds[i][0].dy)
        ..quadraticBezierTo(
          size.width * folds[i][1].dx,
          size.height * folds[i][1].dy,
          size.width * folds[i][2].dx,
          size.height * folds[i][2].dy,
        );

      canvas.drawPath(path, i.isEven ? highlightPaint : shadowPaint);
    }

    canvas.restore();

    canvas.drawPath(
      outline,
      Paint()
        ..color = const Color(0xFF8E805D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CrumpledBallPainter oldDelegate) => false;
}
