import 'package:flutter/material.dart';
import 'package:resilify/widgets/custom_app_bar.dart';
import 'package:resilify/widgets/custom_bottom_navigation.dart';

class MythBusting extends StatelessWidget {
  const MythBusting({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myth Busting',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MythBustingHome(),
    );
  }
}

class MythBustingHome extends StatefulWidget {
  const MythBustingHome({super.key});

  @override
  _MythBustingHomeState createState() => _MythBustingHomeState();
}

class _MythBustingHomeState extends State<MythBustingHome> {
  int _currentIndex = 0;
  int _questionIndex = 0;
  int _correctAnswers = 0;
  bool _showFeedback = false;
  bool _isCorrect = false;
  bool _quizCompleted = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What does OCD stand for?',
      'answers': [
        'Obsessive-Compulsive Disorder',
        'Overthinking-Compulsion Disorder',
        'Obsessional-Conscious Disorder',
        'Over-Controlled Decisions'
      ],
      'correctIndex': 0
    },
    {
      'question': 'Which of the following is a key characteristic of OCD?',
      'answers': [
        'Occasional worrying',
        'Repetitive, unwanted thoughts and compulsive behaviors',
        'Forgetfulness',
        'Lack of interest in daily activities'
      ],
      'correctIndex': 1
    },
    {
      'question': 'What is an example of an obsessive thought in OCD?',
      'answers': [
        'Checking emails regularly',
        'Fear of germs leading to excessive handwashing',
        'Forgetting where you placed your keys',
        'Making a daily to-do list'
      ],
      'correctIndex': 1
    },
    {
      'question': 'Which of the following is NOT a common type of OCD?',
      'answers': [
        'Symmetry & Ordering',
        'Cleaning & Contamination',
        'Schizophrenia-Induced OCD',
        'Forbidden Thoughts'
      ],
      'correctIndex': 2
    },
    {
      'question': 'What is the role of compulsions in OCD?',
      'answers': [
        'They are voluntary actions people enjoy doing',
        'They temporarily relieve anxiety caused by obsessions',
        'They help people focus better at work',
        'They have no connection to obsessions'
      ],
      'correctIndex': 1
    },
    {
      'question': 'Which brain chemical is thought to be involved in OCD?',
      'answers': ['Dopamine', 'Serotonin', 'Cortisol', 'Adrenaline'],
      'correctIndex': 1
    },
    {
      'question':
      'What is the difference between OCD-related hoarding and hoarding disorder?',
      'answers': [
        'OCD-related hoarding is driven by compulsions and fears',
        'There is no difference between the two',
        'Hoarding disorder involves more cleanliness',
        'OCD-related hoarding does not interfere with daily life'
      ],
      'correctIndex': 0
    },
    {
      'question': 'What is the most recommended type of therapy for OCD?',
      'answers': [
        'Exposure and Response Prevention (ERP)',
        'Psychoanalysis',
        'Hypnotherapy',
        'Group therapy'
      ],
      'correctIndex': 0
    },
    {
      'question': 'Which of the following statements about OCD is FALSE?',
      'answers': [
        'OCD is just about being neat and organized',
        'OCD can significantly interfere with daily life',
        'People with OCD often recognize their thoughts are irrational',
        'OCD can be treated with therapy and medication'
      ],
      'correctIndex': 0
    },
    {
      'question':
      'What is Pediatric Autoimmune Neuropsychiatric Disorder Associated with Streptococcus (PANDAS)?',
      'answers': [
        'A type of OCD triggered by a strep infection',
        'A form of OCD only found in adults',
        'A subtype of schizophrenia',
        'A common treatment for OCD'
      ],
      'correctIndex': 0
    },
  ];

  void _onAnswerSelected(int index) {
    setState(() {
      _isCorrect = index == _questions[_questionIndex]['correctIndex'];
      _showFeedback = true;
      if (_isCorrect) _correctAnswers++;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (_questionIndex < _questions.length - 1) {
          _questionIndex++;
        } else {
          _quizCompleted = true;
        }
        _showFeedback = false;
      });

      if (_quizCompleted) {
        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            _questionIndex = 0;
            _correctAnswers = 0;
            _quizCompleted = false;
          });
        });
      }
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: CustomAppBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/img/Myth_Bursting.png',
                width: 100, height: 100),
            const SizedBox(height: 10),
            const Text(
              'Myth-Busting',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child:
                _quizCompleted ? _buildResultScreen() : _buildQuizSection(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildQuizSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _questions[_questionIndex]['question'],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Column(
          children: List.generate(4, (index) {
            return GestureDetector(
              onTap: () => _onAnswerSelected(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _questions[_questionIndex]['answers'][index],
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        if (_showFeedback)
          Text(
            _isCorrect ? "Correct! 🎉" : "Wrong",
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
      ],
    );
  }

  Widget _buildResultScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Quiz Completed!",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.purple),
          ),
          const SizedBox(height: 10),
          Text(
            "You got $_correctAnswers out of ${_questions.length} correct!",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          const Text("Restarting quiz in 3 seconds..."),
        ],
      ),
    );
  }
}