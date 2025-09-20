import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../src/settings/settings_model.dart';
import '../src/settings/settings_service.dart';
import '../util/app_colors.dart';

class GoalWidget extends StatefulWidget {
  const GoalWidget({super.key});

  @override
  State<GoalWidget> createState() => _GoalWidgetState();
}

class _GoalWidgetState extends State<GoalWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        // The main container with rounded corners and a white background.
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
        height: 100,
        child: Row(
          children: [
            // A simple container for the icon with a rounded corner.
            Container(
              height: 100,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/images/concentric.svg', // Replace with your SVG file path
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Main content area
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(),
              ),
            ),
            // The "Set Goal" button.
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  _showSettingsDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardBackground,
                  foregroundColor: AppColors.textPrimary,
                  elevation: 2,
                  shadowColor: AppColors.shadowColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(color: AppColors.borderColor, width: 1),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(
                    'Set Goal',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    double screenTimeGoal = 2.0;
    bool dailyReminderEnabled = false;
    TimeOfDay reminderTime = const TimeOfDay(hour: 8, minute: 0);

    // Load current settings
    final settings = SettingsService.getSettings();
    screenTimeGoal = settings.screenTimeGoal;
    dailyReminderEnabled = settings.dailyReminderEnabled;
    reminderTime = TimeOfDay(
      hour: settings.reminderHour,
      minute: settings.reminderMinute,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Set Goals & Reminders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Screen Time Goal
                    const Text(
                      'Screen Time Goal (hours)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${screenTimeGoal.toStringAsFixed(1)}h'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SliderTheme(
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
                              value: screenTimeGoal,
                              min: 0,
                              max: 12,
                              divisions: 24,
                              onChanged: (val) {
                                setState(() {
                                  screenTimeGoal = val;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Daily Reminder
                    CheckboxListTile(
                      title: const Text('Daily Reminder for Journal'),
                      value: dailyReminderEnabled,
                      activeColor: AppColors.primaryBlue,
                      checkColor: Colors.white,
                      onChanged: (val) {
                        setState(() {
                          dailyReminderEnabled = val ?? false;
                        });
                      },
                    ),
                    if (dailyReminderEnabled) ...[
                      const SizedBox(height: 8),
                      ListTile(
                        title: const Text('Reminder Time'),
                        subtitle: Text(reminderTime.format(context)),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: reminderTime,
                            builder: (BuildContext context, Widget? child) {
                              return MediaQuery(
                                data: MediaQuery.of(
                                  context,
                                ).copyWith(alwaysUse24HourFormat: false),
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
                            setState(() {
                              reminderTime = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Save settings
                    final newSettings = Settings(
                      screenTimeGoal: screenTimeGoal,
                      dailyReminderEnabled: dailyReminderEnabled,
                      reminderHour: reminderTime.hour,
                      reminderMinute: reminderTime.minute,
                    );
                    await SettingsService.saveSettings(newSettings);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings saved successfully!'),
                        ),
                      );
                    }
                  },
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
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
