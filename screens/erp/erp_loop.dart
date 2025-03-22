import 'package:flutter/foundation.dart'; // to check the platform either web/android
import 'package:flutter/material.dart'; //ui
import 'package:resilify/core/app_colors.dart';
import 'package:resilify/widgets/custom_app_bar.dart';
import 'package:just_audio/just_audio.dart'; //for audio playback
import 'package:record/record.dart'; // android voice recording
import 'package:rive/rive.dart'; //animations
import 'package:path_provider/path_provider.dart'; //to store recording in android
import 'dart:io'; //to access files in android env
import 'package:microphone/microphone.dart'; // web voice recording
import 'package:permission_handler/permission_handler.dart'; //to get mic permission
import "package:pie_timer/pie_timer.dart"; //timer widget
import "package:resilify/widgets/duration_picker.dart"; //customised duration picker widget
import 'dart:async'; //for balloon appearing timers
import "package:resilify/widgets/exit_confirmation_dialogue.dart";
import "package:resilify/widgets/timer.dart"; //customised timer widget
import "package:resilify/widgets/microphone.dart"; //customised mic widget
import "package:resilify/widgets/mascot.dart"; //mascot widget
import 'package:resilify/widgets/balloon.dart'; //balloon widget
import 'package:resilify/services/hive_service.dart';
import 'package:resilify/services/auth_service.dart'; // Add this import for AuthService

class ERPLoopPage extends StatefulWidget {//stateful bc the animations and widgets change states
  const ERPLoopPage({super.key});
  @override
  _ERPLoopPageState createState() => _ERPLoopPageState();
}
class _ERPLoopPageState extends State<ERPLoopPage> with TickerProviderStateMixin {
  late RiveAnimationController _eyeBlinkController; //animation controller for mascot
  late RiveAnimationController _talkingController;
  late RiveAnimationController _micController; //mic animation controllers
  late RiveAnimationController _waveDisplayStartRecordController;
  late RiveAnimationController _listeningController;
  late RiveAnimationController _binDisplayEndRecordController;
  late RiveAnimationController _deleteRecordController;
  late RiveAnimationController _balloonFloat; //balloon animation controllers
  late RiveAnimationController _balloonPop;
  bool isTalking = false;
  String currentState ='idle'; //at the start, the state is idle for mic animation
  late MicrophoneRecorder _microphoneRecorder; //web voice recording controller
  late AudioPlayer _audioPlayer; //audio playback controller
  var record = AudioRecorder(); //android voice recording controller
  bool hasRecording = false;
  String? recordingPath;
  late PieAnimationController _pieAnimationController; //timer controller
  DateTime? _startTime; //start time of the timer/game
  Duration _elapsedTime = Duration.zero; //elapsed time of the timer
  DateTime? _pauseStartTime; //starting time to calculate pause duration if user tries to go back mid game
  Duration _pauseDuration = Duration.zero;
  bool paused = false; //game state
  Duration _duration = const Duration(hours: 0, minutes: 20); //default start time of the timer
  bool gameStarted = false; //game state
  bool gameEnded = false;
  bool balloonVisible = false;
  Timer? _timer; //timer for balloon appearing
  int _stars = 0; //stars collected
  final HiveService _hiveService = HiveService(); //hive service to store data
  final AuthService _authService = AuthService(); // Add AuthService
  String? _currentUserId; // Add variable to store current user ID
 
  @override
  void initState() {
    super.initState();
    _eyeBlinkController = SimpleAnimation('blinking'); //eye blinking animation always playing
    _talkingController = SimpleAnimation('talking', autoplay: false);
    _micController = SimpleAnimation('idle');
    _waveDisplayStartRecordController = SimpleAnimation('start record', autoplay: false);
    _listeningController = SimpleAnimation('recording', autoplay: false);
    _binDisplayEndRecordController = SimpleAnimation('end record', autoplay: false);
    _deleteRecordController = SimpleAnimation('delete', autoplay: false);
    _audioPlayer = AudioPlayer(); //initialize audio player
    _microphoneRecorder = MicrophoneRecorder()..init(); //initialize web voice recorder
    _balloonFloat = SimpleAnimation('Idle');
    _balloonPop = SimpleAnimation('Plop', autoplay: false);
    
    // Get current user ID
    _currentUserId = _authService.currentUserId;
  }

  @override
  void dispose() {
    _pieAnimationController.dispose();
    super.dispose();
  }

  void _updateMicState(String newState) {
    setState(() {
      currentState = newState;
    });
  }

  void _startRecording() async {
    _updateMicState('start record');
     _waveDisplayStartRecordController.isActive = true; //transition animation from mic to recording waves
    Future.delayed(Duration(milliseconds: 500), () {
     _updateMicState('recording');
     _listeningController.isActive = true; //animation of recording waves
    });
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (!status.isGranted) {
        return; //exit if permission is not granted
      }
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/myFile.m4a';
      await record.start(const RecordConfig(), path: path);
    } else {
      _microphoneRecorder.start(); //for web voice recording, permmission asked directly by package
    }
  }

  void _stopRecording() async {
    if (!kIsWeb) {
      recordingPath = await record.stop();
      if (recordingPath != null && File(recordingPath!).existsSync()) {
        print("Recording saved successfully at: $recordingPath");
        hasRecording = true; //setting the recording at a file path for android
      } else {
        hasRecording = false;
      }
    } else {
      _microphoneRecorder.stop(); //for web it automatically saves the recording in a blob url
      hasRecording = true;
    }
    _updateMicState('end record');
    _binDisplayEndRecordController.isActive = true; //transition animation from recording waves to bin
  }

  void _deleteRecording() {
    _updateMicState('delete');
      _deleteRecordController.isActive = true; // transition animation from bin to mic (idle)
      hasRecording = false;
      Future.delayed(Duration(milliseconds: 800), () async { // Wait for the delete animation to complete before resetting
        if (!kIsWeb) {
          await record.cancel();
          record.dispose();
        } else {
          _microphoneRecorder.stop();
        }
        _updateMicState('idle');
          _micController = SimpleAnimation('idle'); // re-initialize mic animation 
          _microphoneRecorder = MicrophoneRecorder()..init(); // re-initialize web recorder after calling stop function
          record = AudioRecorder(); // re-initialize android recorder after calling dispose
      });
  }

  void _handleTap() {//for mic animation state controlling
    if (currentState == 'idle') {
      _startRecording();
    } else if (currentState == 'recording') {
      _stopRecording();
    } else if (currentState == 'end record') {
      _deleteRecording();
    }
  }

  void _startTimer() {
    _startTime = DateTime.now();
    _pieAnimationController.startAnim?.call(); //start the pie timer animation
  }

  void _pauseTimer() {
    _pieAnimationController.stopAnim?.call(); //stop the pie timer animation
  }

  void _startTalking() {//mascot animation triggers
    setState(() {
      isTalking = true;
      _talkingController.isActive = true;
    });
  }

  void _stopTalking() {
    setState(() {
      isTalking = false;
      _talkingController.isActive = false;
    });
  }

  void _balloonPopping() { //balloon popping animation triggers
    setState(() {
      _balloonPop.isActive = true;
      Future.delayed(Duration(milliseconds: 800), () { //delaying so that the animation completes before the balloon widget disappears
        setState(() {
          balloonVisible = false;
        });
      });
    });
  }
  
  void _balloonTap() { //ontap controller for balloon widget
    if (balloonVisible = true) {
      _balloonPopping();
    } 
  }

  _startGame() async {//initialize timer controller only when the game starts to prevent the rebuilding of the widget with each time picking state
      _pieAnimationController = PieAnimationController(
      vsync: this,
    );
    
    setState(() {
      gameStarted = true; 
    });
    await Future.delayed(Duration(seconds: 1)); //delay to show the timer animation appear
    _startTimer(); // Start the timer animation
    _timer = Timer.periodic(Duration(seconds: 20), (timer) {
      //timer to make balloons appear
      if (!gameStarted) {
        timer.cancel();
        return;
      }
      setState(() {
        balloonVisible = true;
      });

      if (balloonVisible && !paused) {
        Future.delayed(Duration(seconds: 11), () async {
          if (gameEnded) {
            timer.cancel();
            return;
          }
          if (balloonVisible) {
            timer.cancel();
            _pauseGame();
            _elapsedTime = DateTime.now().difference(_startTime!);

            if (_elapsedTime.inMilliseconds < _duration.inMilliseconds / 2) {
              if (_currentUserId != null) {
                // Add check for user ID
                _hiveService.saveGameSession(
                  uid: _currentUserId!, 
                  timePlayed: _startTime!, 
                  duration: _elapsedTime.inMinutes, 
                  points: _stars
                );
              }
              Navigator.pushReplacementNamed(context, '/game_over');
            } else {
              _stars = 3;
              if (_currentUserId != null) {
                // Add check for user ID
                _hiveService.saveGameSession(
                  uid: _currentUserId!, 
                  timePlayed: _startTime!, 
                  duration: _elapsedTime.inMinutes, 
                  points: _stars
                );
              }
              Navigator.pushReplacementNamed(context, '/halfway_victory');
            }
          }
        });
      }
    });
    while (_elapsedTime < _duration) {//while the set duration is met
      if (!kIsWeb) {//if android
        await _audioPlayer.setFilePath(recordingPath!);
      } else { //for web
        await _audioPlayer.setUrl(_microphoneRecorder.value.recording!.url);
      }
      _audioPlayer.setPitch(1.4); //setting pitch (works only on android)
      _audioPlayer.play(); //starting audio playback
      await Future.delayed(Duration(milliseconds: 500)); // minor delay for the animation to start playing
      _startTalking();
      await _audioPlayer.playerStateStream.firstWhere((playerState) =>
          playerState.processingState ==ProcessingState.completed); //waiting for the audioplayer to complete one cycle
      _stopTalking();
    }
  }

  void _pauseGame(){ //pause game when back button is pressed and confimation box is shown
     _pauseTimer();
     _stopTalking();
    _audioPlayer.pause();
     setState(() { 
      balloonVisible= false;
      paused = true; //prevents the appearance of the balloon widget while game is paused
    });
     _pauseStartTime = DateTime.now(); //starting a pause timer incase user resumes back to game
    _elapsedTime = DateTime.now().difference(_startTime!); //recording the elapsed time if user exits the game
  }

  void _resumeGame(){
    _pauseDuration += DateTime.now().difference(_pauseStartTime!); //calculating the pause duration if user resumes
    setState(() {
      _elapsedTime = DateTime.now().difference(_startTime!) - _pauseDuration; //updating elapsed time deducting pause time
    });
    print(_elapsedTime);
    _pieAnimationController.startAnim?.call(); //resuming timer
    _startTalking();
    _audioPlayer.play(); //resuming audio player
     setState(() { 
      paused = false; 
    });
  }

  @override
  Widget build(BuildContext context) {
     final double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
  if (gameStarted) {
    _pauseGame(); // Pause game state if it's running
    String exitRoute = _elapsedTime.inMilliseconds < _duration.inMilliseconds / 2
        ? '/game_over'
        : '/halfway_victory';
    // Show the exit confirmation dialog and handle navigation based on user confirmation
    bool shouldPop = await showExitConfirmationDialog(
      context,
      exitRoute,
      (userConfirmedExit) {
        if (userConfirmedExit) {
          // Perform the actions if the user confirmed exit
          _audioPlayer.pause();
          if (_elapsedTime.inMilliseconds > _duration.inMilliseconds / 2) {
            _stars = 3;
          }
          if (_currentUserId != null) {
            // Add check for user ID
            _hiveService.saveGameSession(
              uid: _currentUserId!,
              timePlayed: _startTime!, 
              duration: _elapsedTime.inMinutes, 
              points: _stars
            );
          }
          Navigator.pushReplacementNamed(context, exitRoute); // Navigate to the exit route
        } else {
          // Perform actions if the user canceled exit
          _resumeGame(); 
        }
      },
    );
    return shouldPop; // Only pop if confirmed (shouldPop is true)
  }
  return true;
},
      child: Scaffold(
       // backgroundColor: const Color.fromARGB(255, 224, 213, 236),
        appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomAppBar(),
      ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50, width: 20),
            SizedBox(
              child: gameStarted
                  ? PieTimerWidget(
                      pieAnimationController: _pieAnimationController,
                      duration: _duration,
                      onCompleted: () => {
                            _audioPlayer.pause(),
                            _stopTalking(),
                            setState(() {
                              gameEnded = true;
                            }),
                             _stars = 5,
                             _elapsedTime = _duration,
                             if (_currentUserId != null) {
                               // Add check for user ID
                               _hiveService.saveGameSession(
                                 uid: _currentUserId!,
                                 timePlayed: _startTime!, 
                                 duration: _elapsedTime.inMinutes, 
                                 points: _stars
                               )
                             },
                            Navigator.pushReplacementNamed(context, '/victory'),
                          },
                    )
                  : Text(
                      "Tap on the mic, speak your mind and tap again to stop",
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTextColor,
                      ),
              ),
            ),
            SizedBox(height: 40, width: 20),
           Balloon(balloonVisible: balloonVisible, onTap: _balloonTap, controllers: [_balloonFloat, _balloonPop], ),
           MascotWidget(gameStarted: gameStarted, controllers: [_eyeBlinkController, _talkingController]),
            Visibility(
              visible: !gameStarted,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MicrophoneWidget(
                        onTap: _handleTap,
                        controllers: [ _micController, _waveDisplayStartRecordController, _listeningController, _binDisplayEndRecordController, _deleteRecordController],
                      ),
                      DurationPickerWidget(
                        duration: _duration,
                        onDurationChange: (value) {
                          setState(() {
                            _duration = value;
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: !hasRecording || _duration == Duration.zero? null: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:  const Color.fromRGBO(138, 109, 198, 1),
                          foregroundColor: Colors.white, ),
                        child: const Text('Loop!'),
                      )
                    ],),
                ],),
            ),
          ],),
      ),
    );
  }
}