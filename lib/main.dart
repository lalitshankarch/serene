import 'package:flutter/material.dart';
import 'package:serene/widgets/category_list.dart';
import 'package:serene/widgets/total_time_card.dart';
import 'package:usage_stats/usage_stats.dart';

import 'util/data_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: UsageStatsScreen());
  }
}

class UsageStatsScreen extends StatefulWidget {
  const UsageStatsScreen({super.key});

  @override
  State<UsageStatsScreen> createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State<UsageStatsScreen> {
  int totalUsageMs = 0;
  List<UsageInfo> usageStats = [];
  Map<String, int> categoryTotals = {};
  String message = "Fetching...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Usage Stats")),
      body: message.isNotEmpty
          ? Center(child: Text(message))
          : ListView(
              padding: const EdgeInsets.all(0),
              children: [
                TotalTimeCard(
                  totalUsageMs: totalUsageMs,
                  categoryTotals: categoryTotals,
                  categoryColors: categoryColors,
                ),
                const SizedBox(height: 8),
                ExpansionTile(
                  leading: const Icon(Icons.bar_chart_rounded),
                  collapsedBackgroundColor: Colors.blue.shade50,
                  backgroundColor: Colors.blue.shade50,
                  textColor: Colors.blue.shade900,
                  iconColor: Colors.blue,
                  title: const Text("See Category Breakdown"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: UsageByCategoryList(
                        usageStats: usageStats,
                        categoryColors: categoryColors,
                      ),
                    ),
                  ],
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

      List<UsageInfo> usageStats = await UsageStats.queryUsageStats(
        startDate,
        endDate,
      );

      final filteredStats = usageStats.where((info) {
        final pkg = info.packageName ?? "";
        final time = int.tryParse(info.totalTimeInForeground ?? "0") ?? 0;
        return time > 0 && usageWhitelist.containsKey(pkg);
      }).toList();

      Map<String, int> tempCategoryTotals = {};
      int totalMs = 0;

      for (var info in usageStats) {
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
        message = usageStats.isEmpty ? "No usage data found" : "";
        this.usageStats = filteredStats;
      });
    } catch (e) {
      setState(() => message = "Error: $e");
    }
  }
}
