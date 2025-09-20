import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:serene/src/overview/overview_screen.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'src/journal/journal_model.dart';
import 'src/journal/journal_screen.dart';
import 'src/journal/journal_service.dart';
import 'src/notifications/notification_service.dart';
import 'src/profile/profile_model.dart';
import 'src/profile/profile_screen.dart';
import 'src/profile/profile_service.dart';
import 'src/settings/settings_model.dart';
import 'src/settings/settings_service.dart';
import 'util/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  // Init Hive
  await Hive.initFlutter();

  // Register Adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(JournalEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ProfileAdapter());
  }

  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(SettingsAdapter());
  }

  await SettingsService.init();
  // Init services
  await JournalService.init();
  await ProfileService.init();
  await NotificationService.init();

  final settings = SettingsService.getSettings();
  if (settings.dailyReminderEnabled) {
    await NotificationService.scheduleDailyNotification(
      settings.reminderHour,
      settings.reminderMinute,
    );
  }

  runApp(const MyApp());
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProdWell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: AppColors.background,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: AppColors.navSelected,
          unselectedItemColor: AppColors.navUnselected,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    UsageStatsScreen(),
    JournalScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Set Android system navigation bar and status bar colors
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.background,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: "Overview",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: "Journal"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
          onTap: (index) {
            setState(() => _selectedIndex = index);
          },
        ),
      ),
    );
  }
}
