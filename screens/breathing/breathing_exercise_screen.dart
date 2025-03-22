import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';
import 'dart:math' as math;

class BreathingExerciseScreen extends StatefulWidget {
  final String exerciseTitle;

  const BreathingExerciseScreen({
    super.key,
    required this.exerciseTitle,
  });

  @override
  _BreathingExerciseScreenState createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _phase = "Follow the path";
  bool _isExerciseStarted = false;
  bool _isPaused = false;
  bool _isFirstRun = true;
  bool _isStopped = false;
  bool _isCompleted = false;
  int _remainingSeconds = 300; // 5 minutes in seconds

  // Constants for breathing pattern (in seconds)
  static const int inhaleSeconds = 4;
  static const int holdSeconds = 4;
  static const int exhaleSeconds = 4;
  static const int totalCycleSeconds = inhaleSeconds + holdSeconds + exhaleSeconds;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: totalCycleSeconds),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    )..addListener(() {
      setState(() {
        double animValue = _animation.value;
        if (_isFirstRun) {
          if (animValue < inhaleSeconds / totalCycleSeconds) {
            _phase = "Inhale deeply as the ball rises...";
          } else if (animValue < (inhaleSeconds + holdSeconds) / totalCycleSeconds) {
            _phase = "Hold your breath gently...";
          } else {
            _phase = "Exhale slowly as the ball descends...";
          }
        } else {
          if (animValue < inhaleSeconds / totalCycleSeconds) {
            _phase = "Inhale...";
          } else if (animValue < (inhaleSeconds + holdSeconds) / totalCycleSeconds) {
            _phase = "Hold...";
          } else {
            _phase = "Exhale...";
          }
        }
      });
    });

    // Calculate how many complete breathing cycles we need for the total exercise time
    int totalBreathingCycles = (_remainingSeconds / totalCycleSeconds).ceil();

    // Listen for animation completion and handle it
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // One cycle completed
        if (_isExerciseStarted && !_isPaused && !_isStopped && !_isCompleted) {
          if (_remainingSeconds <= totalCycleSeconds) {
            // This is the last cycle, don't repeat but prepare for completion
            // Let the controller stop naturally at value 1.0 (bottom position)
            Future.delayed(Duration(milliseconds: 1500), () {
              if (mounted) {
                setState(() {
                  _isCompleted = true;
                });
              }
            });
          } else {
            // More cycles to go, reset to beginning
            _controller.reset();
            _controller.forward();
          }
        }
      }
    });

    // Countdown timer that syncs with breathing cycles
    Stream.periodic(Duration(seconds: 1), (i) => i).listen((_) {
      if (_isExerciseStarted && !_isPaused && !_isStopped && !_isCompleted && _remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;

          // Check if we're entering the last cycle
          if (_remainingSeconds == totalCycleSeconds) {
            // Ensure we're starting a fresh cycle for the last one
            _controller.reset();
            _controller.forward();
          }

          // If we've just hit zero, we don't call _completeExercise here
          // The animation listener will handle completion when the animation finishes
        });
      }
    });
  }

  void _startExercise() {
    setState(() {
      _isExerciseStarted = true;
      _isStopped = false;
      _isCompleted = false;
    });
    _controller.forward(); // Start the first cycle
  }

  void _pauseExercise() {
    setState(() {
      _isPaused = true;
    });
    _controller.stop();
  }

  void _resumeExercise() {
    setState(() {
      _isPaused = false;
    });
    _controller.forward();
  }

  void _stopExercise() {
    setState(() {
      _isStopped = true;
      _isPaused = false;
    });
    _controller.stop();
  }

  void _restartExercise() {
    setState(() {
      _isStopped = false;
      _isPaused = false;
      _isCompleted = false;
      _remainingSeconds = 300; // Reset to 5 minutes
      _isFirstRun = true;
      _phase = "Follow the path";
    });
    _controller.reset();
    _controller.forward();
  }

  void _completeExercise() {
    // Get current position in the animation cycle
    double currentValue = _controller.value;

    // If we're already in the exhale phase (between 2/3 and 1.0),
    // simply complete the exhale to the bottom point
    if (currentValue >= 2/3 && currentValue < 1.0) {
      // Already in exhale phase, continue to bottom
      double remaining = 1.0 - currentValue;
      int remainingMs = (remaining * totalCycleSeconds * 1000).toInt();

      _controller.animateTo(1.0, duration: Duration(milliseconds: remainingMs)).then((_) {
        // Once at bottom, pause before showing completion
        Future.delayed(Duration(milliseconds: 3000), () {
          if (mounted) {
            setState(() {
              _isCompleted = true;
            });
          }
        });
      });
    }
    // If we're in inhale (0.0-0.33) or hold phase (0.33-0.67),
    // complete the current cycle to reach bottom
    else {
      // Calculate how much of the full cycle we need to complete
      double targetValue = 1.0;
      double remaining;

      if (currentValue < 2/3) {
        // Need to complete more than just the exhale
        remaining = 1.0 - currentValue;
      } else {
        // Past 1.0, go to the next full cycle
        remaining = 2.0 - currentValue;
      }

      int remainingMs = (remaining * totalCycleSeconds * 1000).toInt();

      _controller.animateTo(targetValue, duration: Duration(milliseconds: remainingMs)).then((_) {
        // Once at bottom, pause before showing completion
        Future.delayed(Duration(milliseconds: 3000), () {
          if (mounted) {
            setState(() {
              _isCompleted = true;
            });
          }
        });
      });
    }
  }

  void _exitExercise() {
    Navigator.pop(context);
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE0B8F9),
              Color(0xFFD4B8F2),
              Color(0xFFC8B8EB),
              Color(0xFFBCB8E4),
            ],
            stops: [0.1, 0.4, 0.7, 0.9],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.exerciseTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Timer Display (only show when not completed)
              if (!_isCompleted)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // Completion Message (only show when completed)
              if (_isCompleted)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 80,
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Great job!",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "We hope you're feeling calmer and more centered.",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _restartExercise,
                            icon: Icon(Icons.replay, color: AppColors.primaryColor),
                            label: Text(
                              'Restart Exercise',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _exitExercise,
                            icon: Icon(Icons.exit_to_app, color: Colors.white),
                            label: Text(
                              'Exit',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor.withOpacity(0.3),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Phase Text (only when exercise is active)
              if (!_isCompleted)
                AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: _isExerciseStarted && !_isStopped ? 1.0 : 0.0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      _phase,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // Breathing Animation (only when not completed)
              if (!_isCompleted)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: CustomPaint(
                      painter: TriangleBreathingPainter(
                        _animation.value,
                        _isExerciseStarted && !_isStopped,
                      ),
                      child: Container(),
                    ),
                  ),
                ),

              // Control Buttons (only when not completed)
              if (!_isCompleted)
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_isExerciseStarted)
                        ElevatedButton(
                          onPressed: () {
                            _startExercise();
                            Future.delayed(Duration(seconds: 36), () {
                              if (mounted) {
                                setState(() {
                                  _isFirstRun = false;
                                });
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Start Exercise',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        Row(
                          children: [
                            if (_isStopped)
                              FloatingActionButton(
                                heroTag: 'restart',
                                onPressed: _restartExercise,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.restart_alt, color: AppColors.primaryColor),
                              )
                            else
                              FloatingActionButton(
                                heroTag: 'stop',
                                onPressed: _stopExercise,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.stop, color: AppColors.primaryColor),
                              ),
                            SizedBox(width: 20),
                            if (!_isStopped)
                              FloatingActionButton(
                                heroTag: 'pauseResume',
                                onPressed: _isPaused ? _resumeExercise : _pauseExercise,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  _isPaused ? Icons.play_arrow : Icons.pause,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TriangleBreathingPainter extends CustomPainter {
  final double animationValue;
  final bool isActive;

  TriangleBreathingPainter(this.animationValue, this.isActive);

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    final pathPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    final ballPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, Colors.white.withOpacity(0.6)],
        stops: [0.2, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(0, 0),
        radius: 20,
      ));

    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15);

    // Calculate equilateral triangle points
    final triangleHeight = size.height * 0.6;
    final sideLength = triangleHeight * 2 / math.sqrt(3);
    final centerX = size.width / 2;
    final startY = size.height * 0.8; // Bottom point
    final topY = startY - triangleHeight;

    final bottomPoint = Offset(centerX, startY);
    final topLeftPoint = Offset(centerX - sideLength/2, topY);
    final topRightPoint = Offset(centerX + sideLength/2, topY);

    // Draw triangle path
    final trianglePath = Path()
      ..moveTo(bottomPoint.dx, bottomPoint.dy)
      ..lineTo(topLeftPoint.dx, topLeftPoint.dy)
      ..lineTo(topRightPoint.dx, topRightPoint.dy)
      ..close();

    canvas.drawPath(trianglePath, pathPaint);

    // Calculate ball position based on animation phase
    Offset ballPosition;

    if (animationValue < 1/3) { // Inhale - bottom to top left
      double t = animationValue * 3;
      ballPosition = Offset(
          lerpDouble(bottomPoint.dx, topLeftPoint.dx, t),
          lerpDouble(bottomPoint.dy, topLeftPoint.dy, t)
      );
    } else if (animationValue < 2/3) { // Hold - top left to top right
      double t = (animationValue - 1/3) * 3;
      ballPosition = Offset(
          lerpDouble(topLeftPoint.dx, topRightPoint.dx, t),
          topLeftPoint.dy
      );
    } else { // Exhale - top right to bottom
      double t = (animationValue - 2/3) * 3;
      ballPosition = Offset(
          lerpDouble(topRightPoint.dx, bottomPoint.dx, t),
          lerpDouble(topRightPoint.dy, bottomPoint.dy, t)
      );
    }

    // Draw the breathing ball
    canvas.drawCircle(ballPosition, 25, glowPaint);
    canvas.drawCircle(ballPosition, 15, ballPaint);
  }

  double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}