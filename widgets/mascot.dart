import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class MascotWidget extends StatelessWidget {
  final bool gameStarted;
  final List<RiveAnimationController> controllers;

  const MascotWidget({
    super.key,
    required this.gameStarted,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: gameStarted ? 350 : 350,
      child: RiveAnimation.asset(
        'assets/animations/mascot_animation.riv',
        controllers: controllers,
      ),
    );
  }
}