import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:resilify/widgets/custom_app_bar.dart';
import 'package:resilify/widgets/custom_bottom_navigation.dart';

class SuccessStories extends StatelessWidget {
  const SuccessStories({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Success Stories',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SuccessStoriesHome(),
    );
  }
}

class SuccessStoriesHome extends StatefulWidget {
  const SuccessStoriesHome({super.key});

  @override
  _SuccessStoriesHomeState createState() => _SuccessStoriesHomeState();
}

class _SuccessStoriesHomeState extends State<SuccessStoriesHome> {
  int _currentIndex = 0;
  final List<bool> _flipped = [false, false, false];
  final List<String> _urls = [
    'https://lumatehealth.com/my-daughters-ocd-journey-cbt-success-story/',
    'https://psychologistsnyc.com/dr-oris-ocd-success-stories/',
    'https://adaa.org/living-with-anxiety/personal-stories/darkness-light-my-ocd-story',
  ];

  void _flipBox(int index) {
    setState(() {
      _flipped[index] = !_flipped[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: CustomAppBar(),
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
                  'assets/img/Success_Stories.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Success Stories',
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
                    children: List.generate(3, (index) {
                      return GestureDetector(
                        onTap: () => _flipBox(index),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return RotationYTransition(
                                turns: animation, child: child);
                          },
                          child: _flipped[index]
                              ? _buildUrlBox(_urls[index])
                              : _buildDefaultBox(index),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildDefaultBox(int index) {
    return Container(
      key: ValueKey('default_$index'),
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 600, minHeight: 100),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Tap to reveal the story',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.purple,
        ),
      ),
    );
  }

  Widget _buildUrlBox(String url) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not launch $url';
        }
      },
      child: Container(
        key: ValueKey(url),
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600, minHeight: 100),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          url,
          textAlign: TextAlign.center,
          softWrap: true,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class RotationYTransition extends AnimatedWidget {
  final Widget child;
  final Animation<double> turns;

  const RotationYTransition(
      {super.key, required this.child, required this.turns})
      : super(listenable: turns);

  @override
  Widget build(BuildContext context) {
    final Matrix4 transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateY(turns.value * 0.25); // Reduced rotation to 90 degrees
    return Transform(
      transform: transform,
      alignment: Alignment.center,
      child: child,
    );
  }
}