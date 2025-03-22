import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';
import 'package:resilify/models/user_main.dart';
import 'package:resilify/services/auth_service.dart';
import 'package:resilify/services/hive_service.dart';
import 'package:rive/rive.dart' as rive;
import 'package:animated_flip_counter/animated_flip_counter.dart';

class Streak extends StatefulWidget {
  const Streak({super.key});

  @override
  _StreakState createState() => _StreakState();
}

class _StreakState extends State<Streak> {
  late rive.RiveAnimationController _flame;
  bool _isFlameOn = false;
  int _value = 2; // a random default value
  final AuthService _authService = AuthService();
  final HiveService _hiveService = HiveService();

  @override
  void initState() {
    super.initState();
    _updateStreakData();
    _lightFire();
    _navigateToHome();
  }

  // Method to get the current streak from Hive and increase
  Future<void> _updateStreakData() async {
    String? currentUserId = _authService.currentUserId;
    if (currentUserId != null) {
      UserMain? userData = _hiveService.getUser(currentUserId);
      if (userData != null) {
        _value = userData.streak!;
      }
      setState(() {
        _value = _value;
      });
      await Future.delayed(Duration(milliseconds: 1000), () {});
      setState(() {
        _value++;
      });
      _hiveService.updateStreak(currentUserId, streak: _value); // Update streak value in Hive
    }
  }

  // Method to animate the fire
  _lightFire() async {
    await Future.delayed(Duration(milliseconds: 1000), () {});
    setState(() {
      _isFlameOn = true;
      _flame = rive.SimpleAnimation('fiire', autoplay: true);
    });
  }

  // Method to navigate to the home screen after a delay
  _navigateToHome() async {
    await Future.delayed(Duration(milliseconds: 5000), () {});
    _goToHome();
  }

  // Method to navigate to home
  void _goToHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goToHome(); // Ensure back button only navigates to home
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // center the children
            crossAxisAlignment:
            CrossAxisAlignment.center, // center horizontally
            children: [
              SizedBox(
                height: 200,
                child: _isFlameOn
                    ? rive.RiveAnimation.asset(
                  'assets/animations/flame.riv',
                  controllers: [_flame],
                )
                    : Image.asset(
                  'assets/img/unstreak.png',
                  height: 210,
                  width: 140,
                ),
              ),
              SizedBox(height: 14),
              AnimatedFlipCounter(
                duration: Duration(milliseconds: 500),
                value: _value,
                textStyle: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTextColor,
                ),
              ),
              Text(
                'Day Streak',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}