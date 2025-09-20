import 'package:hive/hive.dart';
import 'profile_model.dart';

class ProfileService {
  static late Box<Profile> _box;

  static Future<void> init() async {
    _box = await Hive.openBox<Profile>('profileBox');
  }

  static Profile? getProfile() {
    return _box.isNotEmpty ? _box.getAt(0) : null;
  }

  static Future<void> saveProfile(Profile profile) async {
    if (_box.isEmpty) {
      await _box.add(profile);
    } else {
      await _box.putAt(0, profile);
    }
  }
}
