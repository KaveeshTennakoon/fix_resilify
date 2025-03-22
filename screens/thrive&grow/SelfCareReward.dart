import 'package:flutter/material.dart';
import 'package:flutter_scratcher/scratcher.dart';
import 'package:resilify/widgets/custom_app_bar.dart';
import 'package:resilify/widgets/custom_bottom_navigation.dart';

class SelfCareReward extends StatelessWidget {
  const SelfCareReward({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Self-Care Rewards',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SelfCareRewardsHome(),
    );
  }
}

class SelfCareRewardsHome extends StatefulWidget {
  const SelfCareRewardsHome({super.key});

  @override
  _SelfCareRewardsHomeState createState() => _SelfCareRewardsHomeState();
}

class _SelfCareRewardsHomeState extends State<SelfCareRewardsHome> {
  int _currentIndex = 0;
  int _currentQuestionIndex = -1;
  int _score = 0;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the primary reason people with OCD perform rituals?',
      'answers': [
        'A) To experience joy',
        'B) To ease distress from intrusive thoughts',
        'C) To impress others',
        'D) To improve congnitive function'
      ],
      'correctAnswer': 'B',
    },
    {
      'question': 'What is delay discounting?',
      'answers': [
        'A) The tendency to prefer larger, delayed rewards over smaller, immediate ones',
        'B) The tendency to prefer smaller, immediate rewards over larger, delayed ones',
        'C) The ability to delay gratification indefinitely',
        'D) The preference for financial investments over spending'
      ],
      'correctAnswer': 'B',
    },
    {
      'question':
      'Which of the following conditions is commonly associated with elevated delay discounting?',
      'answers': [
        'A) Obsessive-compulsive disorder (OCD)',
        'B) Substance use disorder',
        'C) Schizophrenia',
        'D) Autism spectrum disorder'
      ],
      'correctAnswer': 'B',
    },
    {
      'question':
      'What was a key limitation of prior studies on delay discounting in OCD?',
      'answers': [
        'A) They only included participants from a single country',
        'B) They did not recruit participants with OCD',
        'C) They had small sample sizes and included medicated participants',
        'D) They focused only on teenagers'
      ],
      'correctAnswer': 'C',
    },
    {
      'question':
      'What was the main finding of the Global OCD study regarding delay discounting?',
      'answers': [
        'A) People with OCD had significantly higher delay discounting than healthy participants',
        'B) People with OCD had significantly lower delay discounting than healthy participants',
        'C) People with OCD did not differ from healthy participants in their delay discounting',
        'D) People with OCD preferred smaller rewards more than healthy participants'
      ],
      'correctAnswer': 'C',
    },
    {
      'question':
      'How did the Global OCD study ensure the reliability of its results?',
      'answers': [
        'A) By recruiting only participants from the United States',
        'B) By including only people with mild OCD symptoms',
        'C) By harmonizing the discounting task across multiple research sites',
        'D) By excluding all healthy participants from the study'
      ],
      'correctAnswer': 'C',
    },
    {
      'question':
      'What factor within the OCD group was associated with higher delay discounting?',
      'answers': [
        'A) Impulsivity',
        'B) Depression and anxiety symptoms',
        'C) Medication use',
        'D) Hand-washing rituals'
      ],
      'correctAnswer': 'B',
    },
    {
      'question':
      'What does the study suggest about the relationship between OCD and impulsivity?',
      'answers': [
        'A) People with OCD are highly impulsive',
        'B) People with OCD are compulsive but not necessarily impulsive',
        'C) People with OCD always struggle with delaying gratification',
        'D) People with OCD are less future-oriented than others'
      ],
      'correctAnswer': 'B',
    },
    {
      'question':
      'What is one possible explanation for why people with OCD prioritize immediate relief from rituals?',
      'answers': [
        'A) They have a negative view of the future',
        'B) They lack the ability to experience long-term rewards',
        'C) They do not understand the concept of delay discounting',
        'D) They are unable to make rational decisions'
      ],
      'correctAnswer': 'A',
    },
    {
      'question': 'What was a key strength of the Global OCD study?',
      'answers': [
        'A) It relied solely on self-reported data',
        'B) It was conducted only in the United States',
        'C) It controlled for factors like age, gender, and socioeconomic status',
        'D) It used a very small sample size for better accuracy'
      ],
      'correctAnswer': 'C',
    },
  ];

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      if (_currentQuestionIndex >= _questions.length) {
        _showScore();
        _currentQuestionIndex = 0;
      }
    });
  }

  void _showScore() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Quiz Finished!"),
          content: Text("Your score: $_score/${_questions.length}"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                setState(() {
                  _score = 0;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentQuestion =
    _currentQuestionIndex >= 0 ? _questions[_currentQuestionIndex] : null;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: const CustomAppBar(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Add Image
              Image.asset(
                'assets/img/SelfCare_Rewards.png',
                height: 150, // Adjust the height as needed
              ),
              const SizedBox(height: 10),

              // Add Title
              const Text(
                'Self-Care Rewards',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Fix overflow issue with SingleChildScrollView
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (currentQuestion == null)
                        ElevatedButton(
                          onPressed: _nextQuestion,
                          child: const Text('Start Questions'),
                        )
                      else ...[
                        Text(
                          currentQuestion['question'],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children:
                          currentQuestion['answers'].map<Widget>((answer) {
                            return ScratchCard(
                              key: ValueKey(
                                  '${_currentQuestionIndex}_$answer'), // Unique key to force rebuild
                              answer: answer,
                              correctAnswer: currentQuestion['correctAnswer'],
                              onAnswerSelected: (isCorrect) {
                                if (isCorrect) {
                                  setState(() {
                                    _score++;
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                        ElevatedButton(
                          onPressed: _nextQuestion,
                          child: const Text('Next Question'),
                        ),
                      ],
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
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// SCRATCH CARD WIDGET
class ScratchCard extends StatefulWidget {
  final String answer;
  final String correctAnswer;
  final Function(bool) onAnswerSelected;

  const ScratchCard({
    super.key,
    required this.answer,
    required this.correctAnswer,
    required this.onAnswerSelected,
  });

  @override
  _ScratchCardState createState() => _ScratchCardState();
}

class _ScratchCardState extends State<ScratchCard> {
  bool _isScratched = false;

  @override
  Widget build(BuildContext context) {
    String answerLetter = widget.answer[0];
    bool isCorrect = answerLetter == widget.correctAnswer;

    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Scratcher Widget
            Scratcher(
              brushSize: 30,
              threshold: 50,
              color: const Color.fromARGB(
                  255, 227, 179, 236), // Purple color scratch area
              onThreshold: () {
                if (!_isScratched) {
                  setState(() {
                    _isScratched = true;
                    widget.onAnswerSelected(isCorrect);
                  });
                }
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isScratched
                      ? (isCorrect ? Colors.green : Colors.red)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                      color: const Color.fromARGB(255, 243, 242, 244),
                      width: 2),
                ),
                child: _isScratched
                    ? Text(
                  widget.answer, // Show answer after scratch
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                )
                    : null,
              ),
            ),
            // Overlay "Scratch me" text when not scratched
            if (!_isScratched)
              Positioned(
                top: 30,
                child: Text(
                  "Scratch me",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
