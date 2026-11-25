// throw_animation.dart

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import '../painters/crumple_painter.dart';
import 'package:flutter/rendering.dart';

class ThrowAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onCompleted;

  const ThrowAnimation({super.key, required this.child, this.onCompleted});

  @override
  State<ThrowAnimation> createState() => ThrowAnimationState();
}

class ThrowAnimationState extends State<ThrowAnimation>
    with SingleTickerProviderStateMixin {
  final GlobalKey paperKey = GlobalKey();

  late final AnimationController controller;

  ui.Image? paperImage;
  Size paperSize = Size.zero;

  bool capturing = true;

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

    if (boundary == null || !boundary.hasSize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        capturePaper();
      });
      return;
    }

    try {
      final image = await boundary.toImage(pixelRatio: 1.5);

      if (!mounted) {
        image.dispose();
        return;
      }

      setState(() {
        paperImage = image;
        paperSize = Size(boundary.size.width, boundary.size.height);
        capturing = false;
      });

      controller.forward().whenComplete(() {
        if (mounted) widget.onCompleted?.call();
      });
    } catch (error) {
      if (!mounted) return;

      debugPrint('Paper capture failed: $error');
      setState(() {
        capturing = false;
      });
      controller.forward().whenComplete(() {
        if (mounted) widget.onCompleted?.call();
      });
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
          painter: CrumplePainter(
            image: paperImage!,
            progress: controller.value,
          ),
        );
      },
    );
  }
}
