import 'package:flutter/material.dart';
import 'package:resilify/widgets/custom_app_bar.dart';
import 'package:resilify/widgets/custom_bottom_navigation.dart';
import 'package:resilify/widgets/dashboard_box.dart';
import 'package:resilify/screens/thrive&grow/MythBusting.dart';
import 'package:resilify/screens/thrive&grow/SuccessStories.dart';
import 'package:resilify/screens/thrive&grow/MotivationalVideos.dart';
import 'package:resilify/screens/thrive&grow/SelfCareReward.dart';

class ThriveAndGrow extends StatelessWidget {
  const ThriveAndGrow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Replaced MaterialApp with Scaffold
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purple.shade50,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          "assets/img/dashboard3.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Thrive & Grow',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 245, 243, 243),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Your Wellness Journey Awaits!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 75, 55, 109),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Feature Grid Structure Like Dashboard
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MythBustingHome(),
                          ),
                        );
                      },
                      child: const DashboardBox(
                        imagePath: "assets/img/Myth_Bursting.png",
                        label: "Myth-Busting", subtitle: '',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SuccessStoriesHome(),
                          ),
                        );
                      },
                      child: const DashboardBox(
                        imagePath: "assets/img/Success_Stories.png",
                        label: "Success Stories", subtitle: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const MotivationalVideosHome(),
                          ),
                        );
                      },
                      child: const DashboardBox(
                        imagePath: "assets/img/Motivational_Videos.png",
                        label: "Motivational Videos", subtitle: '',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelfCareRewardsHome(),
                          ),
                        );
                      },
                      child: const DashboardBox(
                        imagePath: "assets/img/SelfCare_Rewards.png",
                        label: "Self-Care Rewards", subtitle: '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
