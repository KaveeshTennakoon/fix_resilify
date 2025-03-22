import 'package:flutter/material.dart';
import 'package:resilify/services/auth_service.dart';
import 'package:resilify/services/streak_service.dart';
import 'package:rive/rive.dart';
import 'package:resilify/core/app_colors.dart';
import 'package:rive/rive.dart';
import 'package:just_audio/just_audio.dart';

class Victory extends StatefulWidget {
  final int? stars;
  
  const Victory({super.key, this.stars});

  @override
  _VictoryState createState() => _VictoryState();
}

class _VictoryState extends State<Victory> {
  late RiveAnimationController _idle; //idle animation
  late RiveAnimationController _open; //content displaying
  late RiveAnimationController _glare; // back glare entering
  late RiveAnimationController _shining; //shining effect animation
  AudioPlayer audioPlayer = AudioPlayer();
  final AuthService _authService = AuthService();
  final StreakService _streakService = StreakService();

    @override
    void initState() {
    super.initState();
    _idle = SimpleAnimation('idle', autoplay: true);
    audioPlayer.setAsset('assets/sounds/victory.mp3');
    audioPlayer.play();
    Future.delayed(Duration(seconds: 5), () {
      _idle.isActive = false;
      _open.isActive = true;
    });
    _open = SimpleAnimation('open', autoplay: false);
    _glare = SimpleAnimation('Glare Open', autoplay: true);
    _shining = SimpleAnimation('Loop', autoplay: true);
    _checkStreakStatusAndNavigate();
  }

  _checkStreakStatusAndNavigate() async {
    String? userId = _authService.currentUser?.uid; // Get the current user ID
    if (userId != null) {
      bool canProceedToStreak = await _streakService.shouldGoToStreak(userId);
      // Navigate based on streak status
      if (canProceedToStreak) {
        // Proceed to streak page
        _navigateToStreak();
      } else {
        // Navigate to home page
        _navigateToHome();
      }
    }
  }

  _navigateToHome() async {
    await Future.delayed(Duration(milliseconds: 10000), () {});
    _goToHome();
    audioPlayer.stop();
  }

  void _goToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  _navigateToStreak() async {
    await Future.delayed(Duration(milliseconds: 10000), () {});
    _goToStreak();
    audioPlayer.stop();
  }

  _goToStreak() async {
    Navigator.pushReplacementNamed(context, '/streak');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goToHome(); // Ensure back button only navigates to home
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryColor.withOpacity(0.7),
        body: Center(
          child: Expanded(
            child: RiveAnimation.asset(
              'assets/animations/game_achievement_badge.riv',
              controllers: [_idle, _open, _glare, _shining],
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}