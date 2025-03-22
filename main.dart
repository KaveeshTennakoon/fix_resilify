import 'package:flutter/material.dart';
import 'package:resilify/core/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resilify/screens/breathing/breathing.dart';
import 'package:resilify/screens/thrive&grow/ThriveAndGrowMain.dart';
import 'package:resilify/screens/thrive&grow/MythBusting.dart';
import 'package:resilify/screens/thrive&grow/MotivationalVideos.dart';
import 'package:resilify/screens/thrive&grow/SuccessStories.dart';
import 'package:resilify/screens/thrive&grow/SelfCareReward.dart';
import 'package:resilify/screens/congnitive/cognitive_input.dart';
import 'package:resilify/screens/congnitive/cognitive_reframed.dart';
import 'package:resilify/screens/congnitive/cognitive_mascot.dart';
import 'package:resilify/screens/erp/erp_loop.dart';
import 'package:resilify/screens/erp/halfway_victory.dart';
import 'package:resilify/screens/erp/streak.dart';
import 'package:resilify/screens/erp/victory.dart';
import 'package:resilify/screens/erp/game_over.dart';
import 'package:resilify/screens/dashboards/home.dart';
import 'package:resilify/screens/landing/landing.dart';
import 'package:resilify/screens/landing/signin.dart';
import 'package:resilify/screens/landing/signup.dart';
import 'package:resilify/screens/landing/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:resilify/services/auth_service.dart';
import 'package:resilify/screens/landing/profile.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import this
import 'package:resilify/services/hive_service.dart'; // Import this
import 'package:path_provider/path_provider.dart'; // Import this

// Entry point for the application
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive first
  await Hive.initFlutter();  // Initialize Hive with Flutter
  await HiveService.initHive(); // Initialize HiveService adapters and boxes

  // Initialize Firebase
  await Firebase.initializeApp();

  // Run the app with authentication provider
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: Resilify(),
    ),
  );
}

class Resilify extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Resilify",
        theme: ThemeData(
          primaryColor: AppColors.primaryColor,
          textTheme: GoogleFonts.interTextTheme(
              Theme.of(context).textTheme
          ),
        ),
        home: AuthWrapper(),
        routes: {
          '/splash': (context) => const Splash(),
          '/landing': (context) => const Landing(),
          '/signin': (context) => Signin(),
          '/signup': (context) => Signup(),
          '/home': (context) => const Home(),
          '/breathing_exercise': (context) => const Breathing(),
          '/ThriveAndGrow': (context) => const ThriveAndGrow(),
          '/MythBusting': (context) => const MythBusting(),
          '/MotivationalVideos': (context) => const MotivationalVideos(),
          '/SuccessStories': (context) => const SuccessStories(),
          '/SelfCareReward': (context) => const SelfCareReward(),
          '/cognitive_input': (context) => const CognitiveInputPage(),
          '/cognitive_reframed': (context) => const CognitiveReframedPage(userInput: ""),
          '/cognitive_mascot': (context) => const CognitiveMascotPage(reframedThought: ""),
          '/erp_loop': (context) => const ERPLoopPage(),
          '/victory': (context) => const Victory(stars: 5),
          '/game_over': (context) => const GameOver(),
          '/streak': (context) => Streak(),
          '/halfway_victory': (context) => HalfwayVictory(stars: 3),
          '/profile': (context) => Profile(),
        }
    );
  }
}

// AuthWrapper handles authentication state changes
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Show splash screen initially
    if (authService.authStateInitialized == false) {
      return Splash();
    }

    // If user is logged in, go to home page, otherwise go to landing
    return authService.isLoggedIn ? Home() : Splash();
  }
}