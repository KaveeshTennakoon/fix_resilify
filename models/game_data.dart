import 'package:hive/hive.dart';

part 'game_data.g.dart';

@HiveType(typeId: 1)
class GameData extends HiveObject {
  @HiveField(0)
  DateTime timePlayed;

  @HiveField(1)
  int duration;

  @HiveField(2)
  int points;

  @HiveField(3)
  String uid;

  GameData({required this.timePlayed, required this.duration, required this.points, required this.uid});

  GameData copyWith({DateTime? timePlayed, int? duration, int? points, String? uid}) {
    return GameData(
      timePlayed: timePlayed ?? this.timePlayed,
      duration: duration ?? this.duration,
      points: points ?? this.points,
      uid: uid ?? this.uid,
    );
  }
}