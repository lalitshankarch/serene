import 'package:flutter/material.dart';
import 'package:usage_stats/usage_stats.dart';

import '../util/data_list.dart';

String _formatDuration(Duration d) {
  if (d.inSeconds < 60) return "${d.inSeconds}s";
  if (d.inMinutes < 60) return "${d.inMinutes}m ${d.inSeconds % 60}s";
  return "${d.inHours}h ${d.inMinutes % 60}m";
}

class UsageByCategoryList extends StatelessWidget {
  final List<UsageInfo> usageStats;
  final Map<String, Color> categoryColors;

  const UsageByCategoryList({
    super.key,
    required this.usageStats,
    required this.categoryColors,
  });

  @override
  Widget build(BuildContext context) {
    // Step 1: Aggregate usage per app package
    Map<String, int> appUsageMap = {};
    for (var info in usageStats) {
      final pkg = info.packageName ?? "";
      final time = int.tryParse(info.totalTimeInForeground ?? "0") ?? 0;
      if (time > 0 && usageWhitelist.containsKey(pkg)) {
        appUsageMap[pkg] = (appUsageMap[pkg] ?? 0) + time;
      }
    }

    // Step 2: Group apps by category
    Map<String, List<MapEntry<String, int>>> categoryMap = {};
    appUsageMap.forEach((pkg, time) {
      final category = usageWhitelist[pkg]!.category;
      categoryMap[category] ??= [];
      categoryMap[category]!.add(MapEntry(pkg, time));
    });

    // Step 3: Remove empty categories and sort apps by usage
    categoryMap.removeWhere((key, value) => value.isEmpty);
    for (var apps in categoryMap.values) {
      apps.sort((a, b) => b.value.compareTo(a.value));
    }

    // Step 4: Sort categories by total time descending
    var sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) {
        int aTotal = a.value.fold(0, (sum, e) => sum + e.value);
        int bTotal = b.value.fold(0, (sum, e) => sum + e.value);
        return bTotal.compareTo(aTotal);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedCategories.map((categoryEntry) {
        final categoryName = categoryEntry.key;
        final apps = categoryEntry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header with color dot
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: categoryColors[categoryName] ?? Colors.grey,
                    ),
                  ),
                  Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // List of apps in the category
              Column(
                children: apps.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          usageWhitelist[entry.key]!.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          _formatDuration(Duration(milliseconds: entry.value)),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
