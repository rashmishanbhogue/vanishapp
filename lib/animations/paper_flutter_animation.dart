// paper_flutter_animation.dart

import 'package:flutter/material.dart';

class PaperFlutterAnimation extends StatefulWidget {
  final Widget child;

  const PaperFlutterAnimation({super.key, required this.child});

  @override
  State<PaperFlutterAnimation> createState() => PaperFlutterAnimationState();
}

class PaperFlutterAnimationState extends State<PaperFlutterAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  late final Animation<double> rotateX;
  late final Animation<double> rotateY;
  late final Animation<double> rotateZ;
  late final Animation<double> floatY;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    rotateX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.007, end: 0.012), weight: 18),
      TweenSequenceItem(tween: Tween(begin: 0.012, end: 0.003), weight: 17),
      TweenSequenceItem(tween: Tween(begin: 0.003, end: 0.014), weight: 17),
      TweenSequenceItem(tween: Tween(begin: 0.014, end: 0.005), weight: 18),
      TweenSequenceItem(tween: Tween(begin: 0.005, end: 0.010), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.010, end: 0.007), weight: 15),
    ]).animate(animationController);

    rotateY = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -0.005, end: 0.003), weight: 18),
      TweenSequenceItem(tween: Tween(begin: 0.003, end: 0.009), weight: 17),
      TweenSequenceItem(tween: Tween(begin: 0.009, end: -0.002), weight: 17),
      TweenSequenceItem(tween: Tween(begin: -0.002, end: -0.007), weight: 18),
      TweenSequenceItem(tween: Tween(begin: -0.007, end: 0.005), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.005, end: -0.005), weight: 15),
    ]).animate(animationController);

    rotateZ = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.001), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.001, end: -0.0005), weight: 35),
      TweenSequenceItem(tween: Tween(begin: -0.0005, end: 0.0), weight: 30),
    ]).animate(animationController);

    floatY = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -12.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -12.0, end: 0.0), weight: 50),
    ]).animate(animationController);

    animationController.repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      child: widget.child,
      builder: (context, child) {
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.002)
          ..rotateX(rotateX.value * 5)
          ..rotateY(rotateY.value * 5)
          ..rotateZ(rotateZ.value * 5);

        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: Transform.translate(
            offset: Offset(0, floatY.value),
            child: child,
          ),
        );
      },
    );
  }
}
