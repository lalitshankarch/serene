import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: UsageStatsScreen());
  }
}

class UsageStatsScreen extends StatefulWidget {
  const UsageStatsScreen({super.key});

  @override
  State<UsageStatsScreen> createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State<UsageStatsScreen> {
  List<UsageInfo> stats = [];
  String message = "Fetching...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Usage Stats")),
      body: message.isNotEmpty
          ? Center(child: Text(message))
          : ListView.builder(
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final stat = stats[index];
                return ListTile(
                  title: Text(stat.packageName ?? "Unknown"),
                  subtitle: Text(
                    "Foreground time: ${stat.totalTimeInForeground} ms",
                  ),
                );
              },
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
      DateTime startDate = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        0,
        0,
        0,
      );

      List<UsageInfo> usageStats = await UsageStats.queryUsageStats(
        startDate,
        endDate,
      );

      setState(() {
        stats = usageStats;
        message = stats.isEmpty ? "No usage data found" : "";
      });
    } catch (e) {
      setState(() => message = "Error: $e");
    }
  }
}
