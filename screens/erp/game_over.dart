import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:just_audio/just_audio.dart';

class GameOver extends StatefulWidget {
  const GameOver({super.key});

  @override
  _GameOverState createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> {
  late RiveAnimationController _rain;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    audioPlayer.setAsset('assets/sounds/rain.mp3');
    audioPlayer.play();
    _rain = SimpleAnimation('rain', autoplay: true);
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(milliseconds: 10000), () {});
    _goToHome();
  }

  void _goToHome() {
    audioPlayer.stop();
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
          child: RiveAnimation.asset(
            'assets/animations/game_over.riv',
            controllers: [_rain],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}