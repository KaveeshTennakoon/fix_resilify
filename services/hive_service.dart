import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:resilify/models/game_data.dart';
import 'package:resilify/models/user_main.dart';
import 'package:resilify/models/sentiment_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HiveService {
  static const String userBoxName = 'user_main';
  static const String gameBoxName = 'game_data';
  static const String sentimentBoxName = 'sentiment_data';

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user ID from Firebase
  String? get currentUserId => _auth.currentUser?.uid;

  // Static method to initialize Hive (called from main.dart)
  static Future<void> initHive() async {
    try {
      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(UserMainAdapter());
      }

      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(GameDataAdapter());
      }

      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SentimentDataAdapter());
      }

      // Open boxes
      await Hive.openBox<UserMain>(userBoxName);
      await Hive.openBox<GameData>(gameBoxName);
      await Hive.openBox<SentimentData>(sentimentBoxName);

      print("Hive initialization successful");
    } catch (e) {
      print("Error initializing Hive: $e");
    }
  }

  // USER OPERATIONS

  // Get user from local Hive storage
  UserMain? getUser(String uid) {
    try {
      final userBox = Hive.box<UserMain>(userBoxName);
      return userBox.get(uid);
    } catch (e) {
      print("Error getting user: $e");
      return null;
    }
  }

  // Save user to both Hive and Firebase
  Future<void> saveUser(UserMain user) async {
    try {
      // Save to Hive for local access
      final userBox = Hive.box<UserMain>(userBoxName);
      await userBox.put(user.uid, user);

      // Save to Firebase
      await _firestore.collection('users').doc(user.uid).set({
        'firstName': user.firstName,
        'lastName': user.lastName,
        'points': user.points ?? 0,
        'streak': user.streak ?? 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("User data saved successfully");
    } catch (e) {
      print("Error saving user: $e");
    }
  }

  // Update user's streak in both Hive and Firebase
  Future<void> updateStreak(String uid, {required int streak}) async {
    try {
      // Update in Hive
      final userBox = Hive.box<UserMain>(userBoxName);
      final user = userBox.get(uid);

      if (user != null) {
        user.streak = streak;
        await userBox.put(uid, user);

        // Update in Firebase
        await _firestore.collection('users').doc(uid).update({
          'streak': streak,
          'lastStreakUpdate': FieldValue.serverTimestamp(),
        });

        print("Streak updated to $streak");
      } else {
        print("User not found for streak update");
      }
    } catch (e) {
      print("Error updating streak: $e");
    }
  }

  // Update user's points in both Hive and Firebase
  Future<void> updatePoints(String uid, {required int points}) async {
    try {
      // Update in Hive
      final userBox = Hive.box<UserMain>(userBoxName);
      final user = userBox.get(uid);

      if (user != null) {
        user.points = points;
        await userBox.put(uid, user);

        // Update in Firebase
        await _firestore.collection('users').doc(uid).update({
          'points': points,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print("Points updated to $points");
      } else {
        print("User not found for points update");
      }
    } catch (e) {
      print("Error updating points: $e");
    }
  }

  // Sync user data from Firebase to Hive
  Future<UserMain?> syncUserFromFirebase(String uid) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;
        final user = UserMain(
          uid: uid,
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          points: userData['points'] ?? 0,
          streak: userData['streak'] ?? 0,
        );

        // Save to Hive
        final userBox = Hive.box<UserMain>(userBoxName);
        await userBox.put(uid, user);

        print("User data synced from Firebase");
        return user;
      }
      print("User document not found in Firebase");
      return null;
    } catch (e) {
      print("Error syncing user from Firebase: $e");
      return null;
    }
  }

  // GAME SESSION OPERATIONS

  // Save game session to both Hive and Firebase
  Future<void> saveGameSession({
    required String uid,
    required DateTime timePlayed,
    required int duration,
    required int points,
    String activityType = 'erp',
  }) async {
    try {
      // Create game data object
      final gameData = GameData(
        timePlayed: timePlayed,
        duration: duration,
        points: points,
        uid: uid,
      );

      // Save to Hive
      final gameBox = Hive.box<GameData>(gameBoxName);
      await gameBox.add(gameData);

      // Add to Firebase
      await _firestore.collection('game_sessions').add({
        'uid': uid,
        'timePlayed': Timestamp.fromDate(timePlayed),
        'duration': duration,
        'points': points,
        'activityType': activityType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update user's total points
      final userBox = Hive.box<UserMain>(userBoxName);
      final user = userBox.get(uid);
      if (user != null) {
        final currentPoints = user.points ?? 0;
        final newPoints = currentPoints + points;
        await updatePoints(uid, points: newPoints);
      }

      print("Game session saved successfully");
    } catch (e) {
      print("Error saving game session: $e");
    }
  }

  // Get user's game sessions from Hive
  List<GameData> getUserGameSessions(String uid) {
    try {
      final gameBox = Hive.box<GameData>(gameBoxName);
      return gameBox.values.where((game) => game.uid == uid).toList();
    } catch (e) {
      print("Error getting user game sessions: $e");
      return [];
    }
  }

  // Sync game sessions from Firebase to Hive
  Future<void> syncGameSessionsFromFirebase(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('game_sessions')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      final gameBox = Hive.box<GameData>(gameBoxName);

      // Clear existing records for this user
      final existingRecords = gameBox.values.where((game) => game.uid == uid).toList();
      for (var record in existingRecords) {
        await record.delete();
      }

      // Add new records from Firebase
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final gameData = GameData(
          timePlayed: (data['timePlayed'] as Timestamp).toDate(),
          duration: data['duration'],
          points: data['points'],
          uid: uid,
        );
        await gameBox.add(gameData);
      }

      print("Game sessions synced from Firebase");
    } catch (e) {
      print("Error syncing game sessions from Firebase: $e");
    }
  }

  // SENTIMENT DATA OPERATIONS

  // Save sentiment data
  Future<void> saveSentimentData(SentimentData sentimentData) async {
    try {
      final sentimentBox = Hive.box<SentimentData>(sentimentBoxName);
      await sentimentBox.put(sentimentData.sentimentId, sentimentData);

      // You can also save to Firebase if needed
      await _firestore.collection('sentiment_data').add({
        'sentimentId': sentimentData.sentimentId,
        'time': Timestamp.fromDate(sentimentData.time),
        'score': sentimentData.score,
        'prompt': sentimentData.prompt,
        'uid': _auth.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Sentiment data saved successfully");
    } catch (e) {
      print("Error saving sentiment data: $e");
    }
  }

  // Check if today is a new day to update streak
  Future<bool> isNewDay(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('game_sessions')
          .where('uid', isEqualTo: uid)
          .orderBy('timePlayed', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return true; // No previous sessions, so it's a new day
      }

      final lastSession = querySnapshot.docs.first.data();
      final lastPlayedDate = (lastSession['timePlayed'] as Timestamp).toDate();

      // Compare the date part only
      final today = DateTime.now();
      final lastPlayedDay = DateTime(lastPlayedDate.year, lastPlayedDate.month, lastPlayedDate.day);
      final currentDay = DateTime(today.year, today.month, today.day);

      return currentDay.isAfter(lastPlayedDay);
    } catch (e) {
      print("Error checking if new day: $e");
      return false;
    }
  }
}