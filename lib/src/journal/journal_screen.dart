import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'journal_model.dart';
import 'journal_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _dayHighlight = TextEditingController();
  final TextEditingController _challenge = TextEditingController();
  final TextEditingController _grateful = TextEditingController();
  final TextEditingController _improvement = TextEditingController();
  String? _moodEmoji; // 😊 😐 😞 etc.

  late Box<JournalEntry> _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<JournalEntry>('journalBox');
  }

  Future<void> _save() async {
    if (_dayHighlight.text.isEmpty &&
        _challenge.text.isEmpty &&
        _grateful.text.isEmpty &&
        _improvement.text.isEmpty &&
        _moodEmoji == null) return;

    // Combine answers into one journal text for sentiment analysis
    final combinedText =
        "Highlight: ${_dayHighlight.text}\n"
        "Challenge: ${_challenge.text}\n"
        "Grateful for: ${_grateful.text}\n"
        "Improvement: ${_improvement.text}\n"
        "Mood: $_moodEmoji";

    await JournalService.addEntry(combinedText);

    // clear inputs
    _dayHighlight.clear();
    _challenge.clear();
    _grateful.clear();
    _improvement.clear();
    setState(() => _moodEmoji = null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved ✨')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = JournalService.getEntries();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nightly Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear all',
            onPressed: () async {
              await JournalService.clearAll();
              setState(() {});
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Emoji mood question
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _emojiOption("😊"),
                _emojiOption("😐"),
                _emojiOption("😞"),
                _emojiOption("😡"),
              ],
            ),
            const SizedBox(height: 10),

            // Four short questions
            _buildQuestion("What was the highlight of your day?", _dayHighlight),
            _buildQuestion("What was your biggest challenge today?", _challenge),
            _buildQuestion("What are you grateful for today?", _grateful),
            _buildQuestion("What could you improve tomorrow?", _improvement),

            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save & Analyze'),
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Past entries (${entries.length})',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: entries.isEmpty
                  ? const Center(child: Text('No entries yet'))
                  : ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final e = entries[index];
                        final dateStr = DateFormat.yMMMd().add_jm().format(e.date);
                        final moodEmoji = e.sentimentScore > 0
                            ? '😊'
                            : (e.sentimentScore < 0 ? '😞' : '😐');
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(e.text, maxLines: 3, overflow: TextOverflow.ellipsis),
                            subtitle: Text('$dateStr • Score: ${e.sentimentScore.toStringAsFixed(2)} $moodEmoji'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: 1,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _emojiOption(String emoji) {
    return GestureDetector(
      onTap: () => setState(() => _moodEmoji = emoji),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: _moodEmoji == emoji ? Colors.blue.shade100 : Colors.grey.shade200,
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
