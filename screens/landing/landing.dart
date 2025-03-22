import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';
import 'package:resilify/widgets/custom_button.dart';

class Landing extends StatelessWidget {
  const Landing({super.key});

  _navigateToSignin(context) {
    Navigator.pushNamed(context, '/signin');
  }

  _navigateToSignup(context) {
    Navigator.pushNamed(context, '/signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // image
                SizedBox(height: 215, child: Image.asset('assets/img/mascot.png')),

                // title
                Text(
                  "Resilify",
                  style: TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    color: AppColors.primaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                //subtitle
                Text(
                  "Reclaim your mind, define your life",
                  style:
                  TextStyle(fontSize: 16, color: AppColors.secondaryTextColor),
                  textAlign: TextAlign.center,
                ),

                SizedBox(
                  height: 150,
                ),

                //sign up button
                CustomButton(
                    text: "GET STARTED",
                    onPress: () {
                      _navigateToSignup(context);
                    }),

                SizedBox(
                  height: 12,
                ),

                //sign in button
                CustomButton(
                    text: "I ALREADY HAVE AN ACCOUNT",
                    backgroundColor: AppColors.fourthColor,
                    foregroundColor: AppColors.primaryTextColor,
                    onPress: () {
                      _navigateToSignin(context);
                    })
              ],
            ),
          )),
    );
  }
}
