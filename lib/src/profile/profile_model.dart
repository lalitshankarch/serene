import 'package:hive/hive.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 1) // Make sure this ID is unique (different from JournalEntry)
class Profile extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int age;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? bio; // optional

  @HiveField(4)
  final String? profileImagePath; // local path or network URL

  Profile({
    required this.name,
    required this.age,
    required this.email,
    this.bio,
    this.profileImagePath,
  });
}
