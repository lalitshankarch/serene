import 'package:hive/hive.dart';

part 'settings_model.g.dart'; // Hive will generate this

@HiveType(typeId: 2) // unique typeId
class Settings extends HiveObject {
  @HiveField(0)
  double screenTimeGoal;

  @HiveField(1)
  bool dailyReminderEnabled;

  @HiveField(2)
  int reminderHour;

  @HiveField(3)
  int reminderMinute;

  Settings({
    required this.screenTimeGoal,
    required this.dailyReminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
  });
}
