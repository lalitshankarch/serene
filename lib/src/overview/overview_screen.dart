// lib/src/overview/usage_stats_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../util/app_colors.dart';
import '../../util/data_list.dart';
import '../../widgets/category_list.dart';
import '../../widgets/goal_widget.dart';
import '../../widgets/total_time_card.dart';
import '../journal/journal_service.dart';
import '../journal/journal_model.dart';

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

  /// sentimentData holds last 7 days entries:
  /// [{ 'date': DateTime, 'label': 'Mon', 'score': double }, ...]
  List<Map<String, dynamic>> sentimentData = [];

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    await _fetchUsageStats();
    _loadSentimentData();
  }

  // ---------------- Usage Stats -----------------------------------------
  Future<void> _fetchUsageStats() async {
    setState(() => message = "Fetching...");
    try {
      bool? granted = await UsageStats.checkUsagePermission();
      if (granted != true) {
        // ask permission and early return — user needs to grant and restart flow
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

  // ---------------- Sentiment chart data (last 7 days) -------------------
  void _loadSentimentData() {
    final List<JournalEntry> entries = JournalService.getEntries();

    // build last 7 dates (oldest first)
    final now = DateTime.now();
    final List<DateTime> days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });

    final List<Map<String, dynamic>> data = [];

    for (final day in days) {
      // collect entries that match the date (year, month, day)
      final dayEntries = entries.where((e) {
        final dt = e.date;
        return dt.year == day.year &&
            dt.month == day.month &&
            dt.day == day.day;
      }).toList();

      double avg = 0.0;
      if (dayEntries.isNotEmpty) {
        final sum = dayEntries.fold<double>(
          0.0,
          (prev, el) => prev + (el.sentimentScore),
        );
        avg = sum / dayEntries.length;
      }

      data.add({
        'date': day,
        'label': DateFormat('E').format(day), // Mon, Tue, ...
        'score': avg,
      });
    }

    setState(() => sentimentData = data);
  }

  // ---------------- UI: Chart widget ------------------------------------
  Widget _buildSentimentChart() {
    if (sentimentData.isEmpty) {
      return Center(
        child: Text(
          "No journal sentiment data yet — write something in the Journal.",
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    // prepare spots
    final spots = sentimentData.asMap().entries.map((entry) {
      final idx = entry.key.toDouble();
      final score = (entry.value['score'] as num).toDouble();
      return FlSpot(idx, score);
    }).toList();

    // compute Y range (nice padding)
    double minScore = sentimentData
        .map((e) => (e['score'] as num).toDouble())
        .fold<double>(double.infinity, (prev, el) => min(prev, el));
    double maxScore = sentimentData
        .map((e) => (e['score'] as num).toDouble())
        .fold<double>(double.negativeInfinity, (prev, el) => max(prev, el));

    if (minScore == double.infinity) minScore = 0.0;
    if (maxScore == double.negativeInfinity) maxScore = 0.0;

    // Add some padding but keep symmetrical if possible
    final double padding = max(1.0, ((maxScore - minScore).abs()) * 0.3);
    double chartMinY = minScore - padding;
    double chartMaxY = maxScore + padding;

    // If values are identical (all zeros), set a small range centered at 0
    if ((chartMaxY - chartMinY).abs() < 0.5) {
      chartMinY = -1.0;
      chartMaxY = 1.0;
    }

    return SizedBox(
      height: 220,
      child: Card(
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LineChart(
            LineChartData(
              minY: chartMinY,
              maxY: chartMaxY,
              gridData: FlGridData(show: false, drawHorizontalLine: false),
              borderData: FlBorderData(
                show: true,
                border: const Border(
                  left: BorderSide(color: AppColors.borderColor),
                  bottom: BorderSide(color: AppColors.borderColor),
                  top: BorderSide(color: Colors.transparent),
                  right: BorderSide(color: Colors.transparent),
                ),
              ),

              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text(''),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < sentimentData.length) {
                        final label = sentimentData[idx]['label'] as String;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    interval: 1,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      // Show integer ticks where appropriate
                      return Text(
                        value.toStringAsFixed(1),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      );
                    },
                    interval: ((chartMaxY - chartMinY) / 4).clamp(
                      0.5,
                      double.infinity,
                    ),
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.primaryBlue,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primaryBlue.withOpacity(0.12),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchSpots) {
                    return touchSpots.map((tSpot) {
                      final idx = tSpot.x.toInt();
                      final dt = sentimentData[idx]['date'] as DateTime;
                      final label = DateFormat.yMMMd().format(dt);
                      return LineTooltipItem(
                        "$label\nScore: ${tSpot.y.toStringAsFixed(2)}",
                        TextStyle(color: AppColors.textPrimary),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- build UI -------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
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
                  onPressed: _refreshAll,
                ),
              ],
            ),
          ),

          // content
          Expanded(
            child: message.isNotEmpty
                ? Center(child: Text(message))
                : ListView(
                    padding: const EdgeInsets.all(0),
                    children: [
                      // Total Time card (existing widget)
                      TotalTimeCard(
                        totalUsageMs: totalUsageMs,
                        categoryTotals: categoryTotals,
                        categoryColors: categoryColors,
                      ),

                      // Category breakdown (existing)
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
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
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

                      // Sentiment chart (7-day)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Weekly Sentiment Trend",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildSentimentChart(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Goals widget (existing)
                      const GoalWidget(),

                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
