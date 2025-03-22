import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:rive/rive.dart';
import 'package:resilify/core/app_colors.dart';
import 'package:resilify/widgets/custom_button.dart';
import 'package:resilify/widgets/custom_bottom_navigation.dart';
import 'package:resilify/widgets/custom_app_bar.dart';
import 'package:resilify/widgets/custom_large_text_field_two.dart';

class CognitiveReframedPage extends StatefulWidget {
  final String userInput;

  const CognitiveReframedPage({super.key, required this.userInput});

  @override
  State<CognitiveReframedPage> createState() => _CognitiveReframedPageState();
}

class _CognitiveReframedPageState extends State<CognitiveReframedPage> {
  late TextEditingController _thoughtController;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player instance
  bool _isLoading = false;
  String? _audioPath; // Path for the generated audio file

  @override
  void initState() {
    super.initState();
    _thoughtController = TextEditingController(text: widget.userInput);
    _prepareTextToSpeech(widget.userInput); // Prepare TTS on page load but don't play it
  }

  @override
  void dispose() {
    _thoughtController.dispose();
    _audioPlayer.dispose(); // Dispose audio player
    super.dispose();
  }

  /// Prepares the AI-generated thought as speech using OpenAI's TTS API but doesn't play it
  Future<void> _prepareTextToSpeech(String text) async {
    final apiKey = "YOUR_OPENAI_API_KEY"; // Replace with actual API key
    final url = "https://api.openai.com/v1/audio/speech";

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "tts-1",
          "voice": "alloy",
          "input": text,
        }),
      );

      if (response.statusCode == 200) {
        Uint8List audioBytes = response.bodyBytes;
        await _prepareAudio(audioBytes); // Save the audio file
      } else {
        print("Error: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Saves the audio file for mobile but doesn't play it
  Future<void> _prepareAudio(Uint8List audioBytes) async {
    try {
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/output.mp3';
      File audioFile = File(filePath);
      await audioFile.writeAsBytes(audioBytes);

      setState(() {
        _audioPath = filePath;
      });
    } catch (e) {
      print("Error saving audio: $e");
    }
  }

  /// Plays the generated audio
  void _playAudio() async {
    if (_audioPath == null) return;

    try {
      await _audioPlayer.play(DeviceFileSource(_audioPath!));
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  /// Handles button click to replay TTS audio and play animation
  void _playAnimationAndAudio() async {
    _playAudio(); // Play audio when button is clicked
    await Future.delayed(const Duration(seconds: 3)); // Allow animation to play
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Header Text
              Text(
                "Here's a Positive Reframe! ✨",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 15),

              // Thought Input Box (Read-Only)
              CustomLargeTextFieldTwo(
                hintText: "AI Generated Thought",
                controller: _thoughtController,
              ),
              const SizedBox(height: 20),

              // Audio Loading Indicator or Listen Button
              if (_isLoading)
                const CircularProgressIndicator()
              else
              // Listen to Thought Button
                CustomButton(
                  text: "Listen to Thought",
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  onPress: _playAnimationAndAudio, // Play TTS on button click
                ),
              const SizedBox(height: 30),

              // Supportive Message
              Text(
                "You are doing great! Keep going! 💜",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 20),

              // Show Rive Animation (Mascot)
              SizedBox(
                width: screenWidth * 0.7,
                height: screenWidth * 0.7,
                child: const RiveAnimation.asset(
                  'assets/animations/mascot_animation.riv',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {},
      ),
    );
  }
}
