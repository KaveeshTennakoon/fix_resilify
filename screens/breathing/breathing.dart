import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';
import 'package:resilify/screens/breathing/breathing_exercise_screen.dart';
import 'package:resilify/screens/breathing/sleep_aid_screen.dart';
import 'package:resilify/widgets/custom_app_bar.dart';

class Breathing extends StatelessWidget {
  const Breathing({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;
    // Calculate card width (screen width minus total horizontal padding and spacing)
    double cardWidth = (screenWidth - (2 * 16) - (2 * 8)) / 3;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomAppBar(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text(
              //       'Hello User!',
              //       style: TextStyle(
              //         fontSize: 24,
              //         fontWeight: FontWeight.bold,
              //         color: AppColors.primaryTextColor,
              //       ),
              //     ),
              //     Row(
              //       children: [
              //         Icon(Icons.local_fire_department,
              //              color: AppColors.tertiaryColor),
              //         Text(' 15',
              //              style: TextStyle(color: AppColors.tertiaryColor)),
              //         SizedBox(width: 8),
              //         Icon(Icons.monetization_on,
              //              color: AppColors.tertiaryColor),
              //         Text(' 280',
              //              style: TextStyle(color: AppColors.tertiaryColor)),
              //       ],
              //     ),
              //   ],
              // ),

              SizedBox(height: 20),

              // Categories Section
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTextColor,
                ),
              ),

              SizedBox(height: 16),

              // Category Cards - Now in a Row without scrolling
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryCard(
                    'Breathing\nExercises',
                    Icons.air,
                    cardWidth,
                        () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.bubble_chart,
                                    color: AppColors.primaryColor),
                                title: Text('Deep Breathing'),
                                subtitle: Text('5 minutes · Beginner'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BreathingExerciseScreen(
                                        exerciseTitle: 'Deep Breathing',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  _buildCategoryCard(
                    'Relaxation\nTechniques',
                    Icons.spa,
                    cardWidth,
                        () {},
                  ),
                  _buildCategoryCard(
                    'Sleep\nAid',
                    Icons.nightlight_round,
                    cardWidth,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SleepAidPlayer(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Recommended Exercises Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended for You',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: TextStyle(color: AppColors.tertiaryColor),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: ListView(
                  children: [
                    _buildExerciseCard(
                      'Deep Breathing Basics',
                      '5 min',
                      'Beginner friendly breathing exercise',
                          () {Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BreathingExerciseScreen(
                            exerciseTitle: 'Deep Breathing Basics',
                          ),
                        ),
                      );},
                    ),
                    _buildExerciseCard(
                      '4-7-8 Breathing',
                      '10 min',
                      'Advanced calming technique',
                          () {},
                    ),
                    _buildExerciseCard(
                      'Box Breathing',
                      '7 min',
                      'Perfect for stress relief',
                          () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, double width, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: AppColors.primaryTextColor),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
      String title, String duration, String description, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: AppColors.fourthColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTextColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              duration,
              style: TextStyle(color: AppColors.tertiaryColor),
            ),
            SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(color: AppColors.secondaryTextColor),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            color: AppColors.primaryTextColor),
        onTap: onTap,
      ),
    );
  }
}