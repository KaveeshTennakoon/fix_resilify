import 'package:flutter/material.dart';
import 'package:resilify/widgets/custom_app_bar.dart';
import 'package:resilify/widgets/custom_bottom_navigation.dart';
import 'package:url_launcher/url_launcher.dart';

class MotivationalVideos extends StatelessWidget {
  const MotivationalVideos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motivational videos',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MotivationalVideos(),
    );
  }
}

class MotivationalVideosHome extends StatefulWidget {
  const MotivationalVideosHome({super.key});

  @override
  _MotivationalVideosHomeState createState() => _MotivationalVideosHomeState();
}

class _MotivationalVideosHomeState extends State<MotivationalVideosHome> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: const CustomAppBar(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(
                  'assets/img/Motivational_Videos.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Motivational Videos',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildVideoThumbnail('V-lYzR-ZP54'),
                      _buildVideoThumbnail('NKSnPWUHXaw'),
                      _buildVideoThumbnail('NMGFE3sHIyg'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildVideoThumbnail(String videoId) {
    final String thumbnailUrl =
        'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    final String videoUrl = 'https://www.youtube.com/watch?v=$videoId';

    return GestureDetector(
      onTap: () async {
        if (await canLaunch(videoUrl)) {
          await launch(videoUrl);
        } else {
          throw 'Could not launch $videoUrl';
        }
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600, minHeight: 150),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Image.network(
              thumbnailUrl,
              fit: BoxFit.cover,
              height: 120,
              width: 200,
            ),
            const SizedBox(height: 8),
            const Text(
              'Watch Video',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}