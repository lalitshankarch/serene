import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../util/app_colors.dart';
import '../profile/profile_model.dart';
import '../settings/settings_model.dart';
import '../settings/settings_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isEditing = false;

  // Settings
  double _screenTimeGoal = 2; // default 2 hours
  bool _dailyReminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  Box<Profile>? _profileBox;
  Settings? _settings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Custom header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 0),
            decoration: const BoxDecoration(color: AppColors.background),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "My Profile",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(_isEditing ? Icons.close : Icons.edit),
                  onPressed: () {
                    setState(() => _isEditing = !_isEditing);
                  },
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: ListView(
                children: [
                  // Profile Form
                  SvgPicture.asset(
                    'assets/images/profile.svg', // Replace with your SVG file path
                    height: 125,
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: "Name",
                            ),
                            enabled: _isEditing,
                            validator: (val) => val == null || val.isEmpty
                                ? "Enter your name"
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Age"),
                            enabled: _isEditing,
                            validator: (val) => val == null || val.isEmpty
                                ? "Enter your age"
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: "Email",
                            ),
                            enabled: _isEditing,
                            validator: (val) => val == null || val.isEmpty
                                ? "Enter your email"
                                : null,
                          ),
                          if (_isEditing) ...[
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 1,
                              ),
                              child: const Text("Save Profile"),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Settings Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Settings",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Screen Time Goal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Screen Time Goal (hours)"),
                            Text("${_screenTimeGoal.toStringAsFixed(1)}h"),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primaryBlue,
                            inactiveTrackColor: AppColors.borderColor,
                            thumbColor: AppColors.primaryBlue,
                            overlayColor: AppColors.primaryBlue.withOpacity(
                              0.2,
                            ),
                            valueIndicatorColor: AppColors.primaryBlue,
                            valueIndicatorTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Slider(
                            value: _screenTimeGoal,
                            min: 0,
                            max: 12,
                            divisions: 24,
                            label: "${_screenTimeGoal.toStringAsFixed(1)}h",
                            onChanged: _isEditing
                                ? (val) {
                                    setState(() => _screenTimeGoal = val);
                                  }
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Daily Reminder
                        CheckboxListTile(
                          title: const Text("Daily Reminder for Journal"),
                          value: _dailyReminderEnabled,
                          activeColor: AppColors.primaryBlue,
                          checkColor: Colors.white,
                          onChanged: _isEditing
                              ? (val) {
                                  setState(
                                    () => _dailyReminderEnabled = val ?? false,
                                  );
                                }
                              : null,
                        ),
                        if (_dailyReminderEnabled)
                          ListTile(
                            title: const Text("Reminder Time"),
                            subtitle: Text(_reminderTime.format(context)),
                            trailing: const Icon(Icons.access_time),
                            onTap: _isEditing ? _pickReminderTime : null,
                          ),
                        if (_isEditing) const SizedBox(height: 20),
                        if (_isEditing)
                          ElevatedButton(
                            onPressed: _saveSettings,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 1,
                            ),
                            child: const Text("Save Settings"),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadSettings();
  }

  Future<void> _loadProfile() async {
    _profileBox = await Hive.openBox<Profile>('profileBox');
    if (_profileBox!.isNotEmpty) {
      final profile = _profileBox!.getAt(0);
      if (profile != null) {
        _nameController.text = profile.name;
        _ageController.text = profile.age.toString();
        _emailController.text = profile.email;
      }
    }
    setState(() {});
  }

  Future<void> _loadSettings() async {
    _settings = SettingsService.getSettings();
    setState(() {
      _screenTimeGoal = _settings!.screenTimeGoal;
      _dailyReminderEnabled = _settings!.dailyReminderEnabled;
      _reminderTime = TimeOfDay(
        hour: _settings!.reminderHour,
        minute: _settings!.reminderMinute,
      );
    });
  }

  Future<void> _pickReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primaryBlue,
                secondary: AppColors.accentBlue,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profile = Profile(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        email: _emailController.text.trim(),
      );

      if (_profileBox!.isEmpty) {
        await _profileBox!.add(profile);
      } else {
        await _profileBox!.putAt(0, profile);
      }

      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully")),
      );
    }
  }

  Future<void> _saveSettings() async {
    if (_settings != null) {
      _settings!
        ..screenTimeGoal = _screenTimeGoal
        ..dailyReminderEnabled = _dailyReminderEnabled
        ..reminderHour = _reminderTime.hour
        ..reminderMinute = _reminderTime.minute;

      await SettingsService.saveSettings(_settings!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Settings saved successfully")),
      );
    }
  }
}
