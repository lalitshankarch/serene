import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../profile/profile_model.dart';
import '../settings/settings_model.dart';
import '../settings/settings_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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

  Future<void> _pickReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profile Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                    enabled: _isEditing,
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter your name" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Age"),
                    enabled: _isEditing,
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter your age" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Email"),
                    enabled: _isEditing,
                    validator: (val) =>
                        val == null || val.isEmpty ? "Enter your email" : null,
                  ),
                  const SizedBox(height: 20),
                  if (_isEditing)
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text("Save Profile"),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            // Settings Section
            const Text(
              "Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20, thickness: 1),
            const SizedBox(height: 12),
            // Screen Time Goal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Screen Time Goal (hours)"),
                Text("${_screenTimeGoal.toStringAsFixed(1)}h"),
              ],
            ),
            Slider(
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
            const SizedBox(height: 20),
            // Daily Reminder
            CheckboxListTile(
              title: const Text("Daily Reminder for Journal"),
              value: _dailyReminderEnabled,
              onChanged: _isEditing
                  ? (val) {
                      setState(() => _dailyReminderEnabled = val ?? false);
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
            if (_isEditing)
              const SizedBox(height: 20),
            if (_isEditing)
              ElevatedButton(
                onPressed: _saveSettings,
                child: const Text("Save Settings"),
              ),
          ],
        ),
      ),
    );
  }
}
