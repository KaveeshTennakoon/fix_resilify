import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resilify/services/auth_service.dart';
import 'package:resilify/services/hive_service.dart';
import 'package:resilify/core/app_colors.dart';
import 'package:resilify/models/user_main.dart';
import 'package:resilify/services/streak_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final hiveService = HiveService();
    final streakService = StreakService();

    return FutureBuilder<Map<String, dynamic>>(
      // This future will run every time the AuthService notifies listeners
      future: _getUserData(authService, hiveService, streakService),
      builder: (context, snapshot) {
        // Default values
        String firstName = "User";
        int streak = 0;
        int points = 0;
        bool showGrayStreak = true;

        // Update with data if available
        if (snapshot.hasData) {
          firstName = snapshot.data!['firstName'];
          streak = snapshot.data!['streak'];
          points = snapshot.data!['points'];
          showGrayStreak = snapshot.data!['showGrayStreak'];
        }

        return AppBar(
          backgroundColor: AppColors.secondaryColor,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: AppColors.primaryTextColor),
                  SizedBox(width: 8),
                  Text(
                      "$firstName",
                      style: TextStyle(color: AppColors.primaryTextColor)
                  ),
                ],
              ),
              Row(
                children: [
                  Text("$streak", style: TextStyle(color: AppColors.primaryTextColor)),
                  const SizedBox(width: 4),
                  Image.asset(
                    showGrayStreak ? 'assets/img/unstreak.png' : 'assets/img/streak.png',
                    height: 25,
                    width: 25,
                  ),
                  const SizedBox(width: 10),
                  Text("$points", style: TextStyle(color: AppColors.primaryTextColor)),
                  const SizedBox(width: 4),
                  Image.asset(
                    'assets/img/star.png',
                    height: 30,
                    width: 30,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getUserData(
      AuthService authService,
      HiveService hiveService,
      StreakService streakService
      ) async {
    String? userId = authService.currentUserId;

    // Default values
    Map<String, dynamic> result = {
      'firstName': 'User',
      'streak': 0,
      'points': 0,
      'showGrayStreak': true
    };

    if (userId != null) {
      UserMain? userData = hiveService.getUser(userId);
      bool streakStatus = await streakService.streakApp(userId);

      if (userData != null) {
        result['firstName'] = userData.firstName;
        result['streak'] = userData.streak ?? 0;
        result['points'] = userData.points ?? 0;
      }

      result['showGrayStreak'] = streakStatus;
    }

    return result;
  }
}