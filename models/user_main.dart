import 'package:resilify/models/UserDTO.dart';
import 'package:hive/hive.dart';

part 'user_main.g.dart';

@HiveType(typeId: 0)
class UserMain extends HiveObject {
  @HiveField(0)
  String uid; // Firebase UID stored in Hive

  @HiveField(1)
  String firstName;

  @HiveField(2)
  String lastName;

  @HiveField(3)
  int? points;  // Make points nullable

  @HiveField(4)
  int? streak;  // Make streak nullable

  UserMain({
    required this.uid,
    required this.firstName,
    required this.lastName,
    this.points = 0,  // Default to 0 if null
    this.streak = 0,  // Default to 0 if null
  });

  // // Convert DTO to Hive Model
  // factory UserMain.fromDTO(String uid, UserDTO dto) {
  //   return UserMain(
  //     uid: uid,
  //     firstName: dto.firstName,
  //     lastName: dto.lastName,
  //     points: dto.points ?? 0,  // If points is null, default to 0
  //     streak: dto.streak ?? 0,  // If streak is null, default to 0
  //   );
  // }

  get userId => null;

  UserMain copyWith({required String firstName, required String lastName, int? points, int? streak}) {
    return UserMain(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      points: points ?? this.points,
      streak: streak ?? this.streak,
    );
  }
}