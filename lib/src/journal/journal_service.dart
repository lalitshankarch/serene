import 'package:hive/hive.dart';
import 'journal_model.dart';
import 'package:sentiment_dart/sentiment_dart.dart';

class JournalService {
  static late Box<JournalEntry> _box;

  static Future<void> init() async {
    _box = await Hive.openBox<JournalEntry>('journalBox');
  }

  /// Add text entry with sentiment analysis
  static Future<void> addEntry(String text) async {
    // Run sentiment analysis
    final SentimentResult result = Sentiment.analysis(text);

    // score (double)
    final double score = result.score;

    // result.words.good & result.words.bad are Map<String,num>
    final Map<String, num> goodMap = result.words.good;
    final Map<String, num> badMap = result.words.bad;

    final List<String> positiveWords = goodMap.keys.toList();
    final List<String> negativeWords = badMap.keys.toList();

    final entry = JournalEntry(
      text: text,
      date: DateTime.now(),
      sentimentScore: score,
      positiveWords: positiveWords,
      negativeWords: negativeWords,
    );

    await _box.add(entry);
  }

  static List<JournalEntry> getEntries() {
    return _box.values.toList();
  }

  static Future<void> clearAll() async => await _box.clear();
}
