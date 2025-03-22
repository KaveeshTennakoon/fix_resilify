import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class Balloon extends StatelessWidget {
  final bool balloonVisible;
  final VoidCallback onTap;
  final List<RiveAnimationController> controllers;

  const Balloon({
    super.key,
    required this.balloonVisible,
    required this.onTap,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: balloonVisible,
      child: SizedBox(
        height: 120,
        child: GestureDetector(
          onTap: onTap, // Calls the function from the parent widget
          child: RiveAnimation.asset(
            'assets/animations/balloon_pop.riv',
            controllers: controllers,
          ),
        ),
      ),
    );
  }
}