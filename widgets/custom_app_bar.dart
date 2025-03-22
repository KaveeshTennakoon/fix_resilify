import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';
import 'package:resilify/services/auth_service.dart';
import 'package:resilify/services/streak_service.dart';
import 'package:resilify/services/hive_service.dart';
import 'package:resilify/models/user_main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({super.key});

  @override
  CustomAppBarState createState() => CustomAppBarState();
}

class CustomAppBarState extends State<CustomAppBar> {
  String firstName = "User";
  int streak = 0;
  int points = 0;
  bool _shouldShowGrayStreak = true;
  final AuthService _authService = AuthService();
  final HiveService _hiveService = HiveService();
  final StreakService _streakService = StreakService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? currentUser = _authService.currentUser;
      if (currentUser != null) {
        // Get data from Hive
        UserMain? userData = _hiveService.getUser(currentUser.uid);

        // Check streak status
        bool streakStatus = await _streakService.streakApp(currentUser.uid);
        print("Streak status (gray streak): $streakStatus");

        if (mounted) {
          setState(() {
            _shouldShowGrayStreak = streakStatus;
            if (userData != null) {
              firstName = userData.firstName;
              streak = userData.streak ?? 0;
              points = userData.points ?? 0;
            }
          });
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.secondaryColor,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User name with icon
          Row(
            children: [
              Icon(Icons.person, color: AppColors.primaryTextColor),
              SizedBox(width: 8),
              Text(
                  firstName,
                  style: TextStyle(color: AppColors.primaryTextColor)
              ),
            ],
          ),

          // Streak and points display
          Row(
            children: [
              // Streak counter and icon
              Text(
                  "$streak",
                  style: TextStyle(color: AppColors.primaryTextColor)
              ),
              const SizedBox(width: 4),
              Image.asset(
                _shouldShowGrayStreak ? 'assets/img/unstreak.png' : 'assets/img/streak.png',
                height: 25,
                width: 25,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.local_fire_department,
                        color: _shouldShowGrayStreak ? Colors.grey : Colors.orange),
              ),

              const SizedBox(width: 10),

              // Points counter and star icon
              Text(
                  "$points",
                  style: TextStyle(color: AppColors.primaryTextColor)
              ),
              const SizedBox(width: 4),
              Image.asset(
                'assets/img/star.png',
                height: 30,
                width: 30,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.star, color: Colors.amber),
              ),
            ],
          ),
        ],
      ),
    );
  }
}