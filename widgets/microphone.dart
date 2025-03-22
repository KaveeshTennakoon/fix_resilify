import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class MicrophoneWidget extends StatelessWidget {
  final VoidCallback onTap;
  final List<RiveAnimationController> controllers;

  const MicrophoneWidget({
    super.key,
    required this.onTap,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: 100,
      child: GestureDetector(
        onTap: onTap, // Calls the function from parent widget
        child: RiveAnimation.asset(
          'assets/animations/record_animation.riv',
          controllers: controllers,
        ),
      ),
    );
  }
}