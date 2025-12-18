import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/components/page_container.dart';
import '../providers/journal_provider.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(journalProvider);

    return PageContainer(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Today's Journal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: TextField(
              enabled: !state.isLocked,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: state.isLocked
                    ? 'Journal locked for today'
                    : 'Write about your day...',
                border: const OutlineInputBorder(),
              ),
              controller: TextEditingController(text: state.content),
              onChanged: (text) =>
                  ref.read(journalProvider.notifier).updateContent(text),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${state.wordCount} words'),
              ElevatedButton(
                onPressed: state.canSave
                    ? () => ref.read(journalProvider.notifier).saveToday()
                    : null,
                child: Text(state.isLocked ? 'Saved' : 'Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
