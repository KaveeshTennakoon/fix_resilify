import 'package:flutter/material.dart';
import 'package:pie_timer/pie_timer.dart';

class PieTimerWidget extends StatelessWidget {
  final PieAnimationController pieAnimationController;
  final Duration duration;
  final VoidCallback onCompleted;


  const PieTimerWidget({
    super.key,
    required this.pieAnimationController,
    required this.duration,
    required this.onCompleted,

  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      width: 70,
      child: PieTimer(
              pieAnimationController: pieAnimationController,
              duration: duration,
              radius: 50,
              fillColor: const Color.fromARGB(255, 186, 149, 207),
              pieColor: const Color.fromARGB(255, 208, 184, 223),
              borderColor: const Color.fromRGBO(138, 109, 198, 1),
              borderWidth: 3,
              shadowColor: Colors.black,
              shadowElevation: 10.0,
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              isReverse: false,
              enableTouchControls: false,
              onCompleted: onCompleted,
            )

    );
  }
}