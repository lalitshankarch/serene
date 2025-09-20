import 'package:hive/hive.dart';

part 'journal_model.g.dart';

@HiveType(typeId: 0)
class JournalEntry extends HiveObject {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final double sentimentScore;

  @HiveField(3)
  final List<String> positiveWords;

  @HiveField(4)
  final List<String> negativeWords;

  JournalEntry({
    required this.text,
    required this.date,
    required this.sentimentScore,
    required this.positiveWords,
    required this.negativeWords,
  });
}
