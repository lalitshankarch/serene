import 'package:hive/hive.dart';
import 'settings_model.dart';

class SettingsService {
  static late Box<Settings> _box;

  static Future<void> init() async {
    _box = await Hive.openBox<Settings>('settingsBox');
    if (_box.isEmpty) {
      await _box.add(Settings(
        screenTimeGoal: 2,
        dailyReminderEnabled: false,
        reminderHour: 8,
        reminderMinute: 0,
      ));
    }
  }

  static Settings getSettings() {
    return _box.getAt(0)!;
  }

  static Future<void> saveSettings(Settings settings) async {
    await _box.putAt(0, settings);
  }
}
