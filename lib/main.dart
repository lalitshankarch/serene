import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:usage_stats/usage_stats.dart';

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
import 'util/data_list.dart';
import 'widgets/category_list.dart';
import 'widgets/goal_widget.dart';
import 'widgets/total_time_card.dart';

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

// -------------------- UsageStatsScreen --------------------
class UsageStatsScreen extends StatefulWidget {
  const UsageStatsScreen({super.key});

  @override
  State<UsageStatsScreen> createState() => _UsageStatsScreenState();
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

class _UsageStatsScreenState extends State<UsageStatsScreen> {
  int totalUsageMs = 0;
  List<UsageInfo> usageStats = [];
  Map<String, int> categoryTotals = {};
  String message = "Fetching...";

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
                  "Overview",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _fetchUsageStats();
                  },
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: message.isNotEmpty
                ? Center(child: Text(message))
                : ListView(
                    padding: const EdgeInsets.all(0),
                    children: [
                TotalTimeCard(
                  totalUsageMs: totalUsageMs,
                  categoryTotals: categoryTotals,
                  categoryColors: categoryColors,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      collapsedBackgroundColor: Colors.transparent,
                      backgroundColor: Colors.transparent,
                      textColor: AppColors.primaryBlue,
                      iconColor: AppColors.primaryBlue,
                      leading: const Icon(Icons.bar_chart_rounded),
                      title: const Text("See Category Breakdown"),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 8.0,
                          ),
                          child: UsageByCategoryList(
                            usageStats: usageStats,
                            categoryColors: categoryColors,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                      const SizedBox(height: 16),
                      const GoalWidget(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUsageStats();
  }

  Future<void> _fetchUsageStats() async {
    try {
      bool? granted = await UsageStats.checkUsagePermission();
      if (granted != true) {
        await UsageStats.grantUsagePermission();
        setState(
          () =>
              message = "Permission not granted. Please allow and restart app.",
        );
        return;
      }

      DateTime endDate = DateTime.now();
      DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day);

      List<UsageInfo> stats = await UsageStats.queryUsageStats(
        startDate,
        endDate,
      );

      final filteredStats = stats.where((info) {
        final pkg = info.packageName ?? "";
        final time = int.tryParse(info.totalTimeInForeground ?? "0") ?? 0;
        return time > 0 && usageWhitelist.containsKey(pkg);
      }).toList();

      Map<String, int> tempCategoryTotals = {};
      int totalMs = 0;

      for (var info in stats) {
        final pkg = info.packageName ?? "";
        final time = int.tryParse(info.totalTimeInForeground ?? "0") ?? 0;
        if (time > 0 && usageWhitelist.containsKey(pkg)) {
          final category = usageWhitelist[pkg]!.category;
          tempCategoryTotals[category] =
              (tempCategoryTotals[category] ?? 0) + time;
          totalMs += time;
        }
      }

      setState(() {
        totalUsageMs = totalMs;
        categoryTotals = tempCategoryTotals;
        message = stats.isEmpty ? "No usage data found" : "";
        usageStats = filteredStats;
      });
    } catch (e) {
      setState(() => message = "Error: $e");
    }
  }
}
