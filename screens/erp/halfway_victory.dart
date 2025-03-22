import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';
import 'package:resilify/services/auth_service.dart';
import 'package:resilify/services/streak_service.dart';
import 'package:rive/rive.dart';

class HalfwayVictory extends StatefulWidget {
  final int? stars;

  const HalfwayVictory({super.key, this.stars});

  @override
  _HalfwayVictoryState createState() => _HalfwayVictoryState();
}

class _HalfwayVictoryState extends State<HalfwayVictory> {
  late RiveAnimationController _idle;
  late RiveAnimationController _open;
  late RiveAnimationController _glare;
  late RiveAnimationController _shining;
  final AuthService _authService = AuthService();
  final StreakService _streakService = StreakService();

  @override
  void initState() {
    super.initState();
    _idle = SimpleAnimation('idle', autoplay: true);
    _open = SimpleAnimation('open', autoplay: false);
    _glare = SimpleAnimation('Glare Open', autoplay: true);
    _shining = SimpleAnimation('Loop', autoplay: true);

    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _idle.isActive = false;
        _open.isActive = true;
      });
    });
    _checkStreakStatusAndNavigate();
  }

  _checkStreakStatusAndNavigate() async {
    String? userId = _authService.currentUserId;
    if (userId != null) {
      bool canProceedToStreak = await _streakService.shouldGoToStreak(userId);
      print("halfway_victory: can i go to streak? $canProceedToStreak");
      if (canProceedToStreak) {
        _navigateToStreak();
      } else {
        _navigateToHome();
      }
    }
  }

  _navigateToStreak() async {
    await Future.delayed(Duration(seconds: 10));
    Navigator.pushReplacementNamed(context, '/streak');
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 10));
    _goToHome();
  }

  void _goToHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goToHome();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryColor.withOpacity(0.7),
        body: Center(
          child: RiveAnimation.asset(
            'assets/animations/game_halfway_badge.riv',
            controllers: [_idle, _open, _glare, _shining],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}