import 'package:resilify/models/game_data.dart';
import 'package:resilify/models/user_main.dart';
import 'package:hive/hive.dart';

class StreakService {
  Future<bool> streakApp(String userId) async {
    //this method is to update the app bar
    var gameBox = Hive.box<GameData>('game_data');
    var userBox = Hive.box<UserMain>('user_main');

    print("All sessions ${gameBox.values.toList().length}");

    List<GameData> userSessions = gameBox.values
        .where((session) => session.uid == userId && session.points > 2)
        .toList(); //getting sessions for a user that has more than 2 points -> streakworthy session -> halfway victory achieved session or victory achieved session
    print("All sessions for user $userId: ${userSessions.toList().length}");

    if (userSessions.isEmpty) {
      return true; // No sessions → Show gray streak , user just made the account situation
    } //

    // Sort sessions from latest to oldest
    userSessions.sort((a, b) => b.timePlayed.compareTo(a.timePlayed));

    GameData? latestStreakWorthySession;

    latestStreakWorthySession =
        userSessions.first; //after sorting, getting the latest session

    print(
        "Latest streak-worthy session: ${latestStreakWorthySession?.timePlayed}");

    DateTime now = DateTime.now();
    DateTime lastPlayedDate = latestStreakWorthySession.timePlayed;

    int hoursDifference = now
        .difference(lastPlayedDate)
        .inHours; //checking the diffrence between that session and now
    var user = userBox.get(userId);
    print("Hours difference from last session: $hoursDifference");
    if (hoursDifference >24 && hoursDifference < 48) {
      return true; // Show gray streak
    }
    if (hoursDifference > 48) {
      //if a streakworthy session isnt played in the last 48 hours
      if (user != null) {
        user.streak = 0;
        await user.save(); //resetting the streak to 0
      }
      return true; // Show gray streak
    }
    else {
      return false; // User played within the last 48 hours → No streak reset or no gray streak
    }
  }

  Future<bool> shouldGoToStreak(String userId) async {
    // this is for the streak increase animated page navigation
    var gameBox = Hive.box<GameData>('game_data');
    var userBox = Hive.box<UserMain>('user_main');
    print("All sessions ${gameBox.values.toList().length}");
    List<GameData> userSessions = gameBox.values
        .where((session) => session.uid == userId && session.points > 2)
        .toList(); //similarly getting the user sessions with the same condition
    print("All sessions for user $userId: ${gameBox.values.toList().length}");

    // Sort sessions from latest to oldest
    userSessions.sort((a, b) => b.timePlayed.compareTo(a.timePlayed)); //sorting

    GameData? latestStreakWorthySession;

    if (userSessions.length == 1) {
      //in this case there cannot be a list empty situation because this method is only called after a game
      return true; // so therefore we check if this is the only game session, if it is, we need to navigate to the streak increase page
    }

    latestStreakWorthySession =
    userSessions[1]; //else, we get the last streakworthy session

    print(
        "Latest streak-worthy session: ${latestStreakWorthySession?.timePlayed}");
    DateTime now = DateTime.now();
    DateTime lastPlayedDate = latestStreakWorthySession.timePlayed;

    int hoursDifference =
        now.difference(lastPlayedDate).inHours; //get the difference as usual
    var user = userBox.get(userId);
    print("Hours difference from last session: $hoursDifference");

    if (hoursDifference > 48) {
      // If last worthy session was over 48 hours ago, reset streak and allow streak update
      if (user != null) {
        user.streak = 0;
        await user.save();
      }
      return true; // proceed to streak increase
    } else {
      return false; // User played within the last 48 hours → No streak reset or no navigation to streak increase page
    }
  }
}