import 'package:resilify/models/UserDTO.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../models/user_main.dart';
import '../models/game_data.dart';
import '../models/sentiment_data.dart';

class HiveService {
  static const String gameSessionsBoxName = 'game_data';

  // Singleton pattern - modified to avoid circular dependency
  static final HiveService _instance = HiveService._internal();

  factory HiveService() {
    return _instance;
  }

  HiveService._internal();

  /// Initialize Hive and register adapters
  static Future<void> initHive() async {
    Hive.registerAdapter(UserMainAdapter());
    Hive.registerAdapter(GameDataAdapter());
    Hive.registerAdapter(SentimentDataAdapter());

    try {
      await Hive.openBox<UserMain>('user_main');
      await Hive.openBox<GameData>('game_data');
      await Hive.openBox<SentimentData>('sentiment_data');
      print("Hive boxes opened successfully.");
    } catch (e) {
      print("Error opening Hive boxes: $e");
    }
  }

  /// Save User with UID
  Future<void> saveUser(String uid, UserDTO userDTO) async {
    var userBox = Hive.box<UserMain>('user_main');

    // Check if user already exists
    UserMain? existingUser = userBox.get(uid);

    if (existingUser != null) {
      // Update existing user
      existingUser.firstName = userDTO.firstName;
      existingUser.lastName = userDTO.lastName;
      existingUser.points = existingUser.points ?? 0;
      existingUser.streak = existingUser.streak ?? 0;
      userBox.put(uid, existingUser);
    } else {
      // Create new user
      var user = UserMain(
        uid: uid,
        firstName: userDTO.firstName,
        lastName: userDTO.lastName,
        points: 0,
        streak: 0,
      );
      userBox.put(uid, user);
    }

    if (kDebugMode) {
      print(
          "✅ User stored: FirstName>${userDTO.firstName} LastName>${userDTO.lastName}, UID > $uid");
    }
  }

  /// Retrieve user by UID
  UserMain? getUser(String uid) {
    var userBox = Hive.box<UserMain>('user_main');
    return userBox.get(uid);
  }

  /// Retrieve stored UID for auto-login
  String? getStoredUID() {
    var userBox = Hive.box<UserMain>('user_main');
    if (userBox.isNotEmpty) {
      return userBox.values.first.uid; // Get first stored UID
    }
    return null;
  }

  /// Update user details
  Future<void> updateUser(String userId,
      {String? firstName, String? lastName}) async {
    var box = Hive.box<UserMain>('user_main');
    var user = box.get(userId);

    if (user != null) {
      user.firstName = firstName ?? user.firstName;
      user.lastName = lastName ?? user.lastName;
      box.put(userId, user);
      if (kDebugMode) {
        print("✅ User updated: $userId");
      }
    } else {
      if (kDebugMode) {
        print("⚠️ User not found: $userId");
      }
    }
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    var box = Hive.box<UserMain>('user_main');
    await box.delete(userId);
    if (kDebugMode) {
      print("🗑️ User deleted: $userId");
    }
  }

  /// Saves game session data locally (Hive)
  Future<void> saveGameSession({
    required String uid,
    required DateTime timePlayed,
    required int duration,
    required int points,
    Function(DateTime, int, int)? syncToBackend,
  }) async {
    var gameBox = Hive.box<GameData>('game_data');

    // Create new game data object
    var newSession = GameData(
      uid: uid,
      timePlayed: timePlayed,
      duration: duration,
      points: points,
    );

    // Save locally for offline access
    await gameBox.add(newSession);
    updatePoints(uid, points: points); // Hive auto-generates key in add method
    if (kDebugMode) {
      print("✅ New game session saved locally");
    }

    // Save to backend if sync function is provided
    if (syncToBackend != null) {
      try {
        await syncToBackend(timePlayed, duration, points);
        if (kDebugMode) {
          print("✅ Game session sent to backend");
        }
      } catch (e) {
        if (kDebugMode) {
          print("⚠️ Failed to send game session to backend: $e");
        }
      }
    }

    print("New game session saved for user $uid");
  }

  // Read all game sessions for user
  List<GameData> getUserGameSessions(String uid) {
    var gameBox = Hive.box<GameData>('game_data');
    return gameBox.values.where((session) => session.uid == uid).toList();
  }

  List<GameData> getAllGameSessions() {
    var gameBox = Hive.box<GameData>('game_data');
    return gameBox.values.toList();
  }

  //update user points
  Future<void> updatePoints(String userId, {required int points}) async {
    var userBox = Hive.box<UserMain>('user_main');
    var user = userBox.get(userId);
    if (user != null ) {
      user.points = (user.points ?? 0) + points;
      await user.save();
    }
  }

  //update user streak
  Future<void> updateStreak(String userId, {required int streak}) async {
    var userBox = Hive.box<UserMain>('user_main');
    var user = userBox.get(userId);
    if (user != null) {
      user.streak = streak;
      await user.save();
    }
  }

  /// Update SentimentData
  Future<void> updateSentiment(String sentimentId,
      {double? score, String? prompt}) async {
    var box = Hive.box<SentimentData>('sentiment_data');
    var sentiment = box.get(sentimentId);

    if (sentiment != null) {
      box.put(
          sentimentId,
          sentiment.copyWith(
            score: score ?? sentiment.score,
            prompt: prompt ?? sentiment.prompt,
          ));
      if (kDebugMode) {
        print("😊 Sentiment updated: $sentimentId");
      }
    } else {
      if (kDebugMode) {
        print("⚠️ Sentiment not found: $sentimentId");
      }
    }
  }

  /// Clear all user data (for logout)
  Future<void> clearUserData() async {
    var userBox = Hive.box<UserMain>('user_main');
    await userBox.clear();
    if (kDebugMode) {
      print("🧹 All user data cleared");
    }
  }

  /// Syncs local game sessions with the backend using the provided function
  Future<void> syncLocalSessionsWithBackend(
      Future<void> Function(DateTime, int, int, String) syncFunction
      ) async {
    if (kDebugMode) {
      print("🔄 Starting sync of local sessions with backend...");
    }

    final sessions = getAllGameSessions();
    int syncCount = 0;

    for (var session in sessions) {
      try {
        await syncFunction(
            session.timePlayed,
            session.duration,
            session.points,
            'erp'
        );
        syncCount++;
      } catch (e) {
        if (kDebugMode) {
          print("⚠️ Failed to sync session: $e");
        }
        // Continue with next session even if this one fails
      }
    }

    if (kDebugMode) {
      print("✅ Synced $syncCount/${sessions.length} sessions with backend");
    }
  }
}