import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';
import 'package:resilify/screens/congnitive/cognitive_chat_history.dart';
import 'package:resilify/widgets/custom_button.dart';
import 'package:resilify/widgets/custom_large_text_field.dart';
import 'package:resilify/widgets/custom_bottom_navigation.dart';
import 'package:resilify/widgets/custom_app_bar.dart';
import 'package:resilify/screens/congnitive/cognitive_reframed.dart';
import 'package:resilify/services/cognitive_reframing_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CognitiveInputPage extends StatefulWidget {
  const CognitiveInputPage({super.key});

  @override
  _CognitiveInputPageState createState() => _CognitiveInputPageState();
}

class _CognitiveInputPageState extends State<CognitiveInputPage> {
  final TextEditingController _thoughtController = TextEditingController();
  bool _isLoading = false;



  Future<void> _handleSubmit() async {
    if (_thoughtController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter your thought"),
          backgroundColor: AppColors.primaryColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    //  Retrieve User ID from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('user_id') ?? 1; // Default to 1 if null

    //  Send Thought along with User ID
    String? reframedThought = await CognitiveReframingAPI.sendThought(
      _thoughtController.text,
      userId, // Pass user ID to API
    );

    setState(() {
      _isLoading = false;
    });

    if (reframedThought != null && !reframedThought.startsWith("Error")) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CognitiveReframedPage(userInput: reframedThought),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reframedThought ?? "Unknown error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomAppBar(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                "What’s on your mind today?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 15),
              CustomLargeTextField(
                hintText: "Type your thought",
                controller: _thoughtController,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator(color: AppColors.primaryColor)
                  : CustomButton(
                text: "Enter",
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                onPress: _handleSubmit,
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: "Chat History",
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                onPress: () async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  int userId1 = prefs.getInt('user_id') ?? 1;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  MessageHistoryScreen(userId: userId1,),
                    ),
                  );

                },
              ),
              Text(
                "Let's reframe this together!",
                style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/img/Cognitive_reframing.png',
                height: screenWidth * 0.5,
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