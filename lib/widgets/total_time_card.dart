import 'package:flutter/material.dart';

String _formatDuration(Duration d) {
  if (d.inSeconds < 60) return "${d.inSeconds}s";
  if (d.inMinutes < 60) return "${d.inMinutes}m ${d.inSeconds % 60}s";
  return "${d.inHours}h ${d.inMinutes % 60}m";
}

class TotalTimeCard extends StatelessWidget {
  final int totalUsageMs;
  final Map<String, int> categoryTotals;
  final Map<String, Color> categoryColors;

  const TotalTimeCard({
    super.key,
    required this.totalUsageMs,
    required this.categoryTotals,
    required this.categoryColors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total screen time",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(Duration(milliseconds: totalUsageMs)),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (categoryTotals.isNotEmpty)
                  SizedBox(
                    height: 20,
                    child: Row(
                      children:
                          (categoryTotals.entries.toList()
                                ..sort((a, b) => b.value.compareTo(a.value)))
                              .asMap()
                              .entries
                              .map((mapEntry) {
                                final index = mapEntry.key;
                                final entry = mapEntry.value;
                                final color =
                                    categoryColors[entry.key] ?? Colors.grey;
                                final fraction = entry.value / totalUsageMs;

                                // Determine border radius
                                BorderRadius borderRadius = BorderRadius.zero;
                                if (index == 0) {
                                  borderRadius = const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomLeft: Radius.circular(8),
                                  );
                                }
                                if (index == categoryTotals.length - 1) {
                                  borderRadius = BorderRadius.only(
                                    topRight: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  );
                                }
                                if (index == 0 &&
                                    index == categoryTotals.length - 1) {
                                  // Only one segment
                                  borderRadius = BorderRadius.circular(8);
                                }

                                return Expanded(
                                  flex: (fraction * 1000).toInt(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: borderRadius,
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                    ),
                  ),
                const SizedBox(height: 16),
                if (categoryTotals.isNotEmpty) ...[
                  const Text(
                    "Breakdown by category",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children:
                        (categoryTotals.entries.toList()
                              ..sort((a, b) => b.value.compareTo(a.value)))
                            .map((entry) {
                              final color =
                                  categoryColors[entry.key] ?? Colors.grey;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 10,
                                          color: color,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          entry.key,
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _formatDuration(
                                        Duration(milliseconds: entry.value),
                                      ),
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })
                            .toList(),
                  ),
                ] else ...[
                  const Text(
                    "No category data available",
                    style: TextStyle(color: Colors.black45),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
