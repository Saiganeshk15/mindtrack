class DetectJournalCategoryUseCase {
  static const Map<String, List<String>> _keywords = {
    'positive': [
      'good',
      'great',
      'grateful',
      'calm',
      'relaxed',
      'proud',
      'hopeful',
      'satisfied',
      'peaceful',
      'relieved',
      'confident',
      'better',
      'progress',
    ],
    'stress': [
      'stress',
      'stressed',
      'pressure',
      'workload',
      'busy',
      'tired',
      'overworked',
      'exhausted',
      'deadline',
      'responsibility',
    ],
    'anxiety': [
      'anxious',
      'anxiety',
      'worried',
      'worry',
      'nervous',
      'fear',
      'panic',
      'uneasy',
      'overwhelmed',
      'uncertain',
    ],
    'sad': [
      'sad',
      'unhappy',
      'down',
      'low',
      'lonely',
      'empty',
      'cry',
      'cried',
      'hopeless',
      'numb',
      'miserable',
    ],
    'angry': [
      'angry',
      'anger',
      'mad',
      'frustrated',
      'irritation',
      'annoyed',
      'rage',
      'upset',
      'furious',
    ],
  };

  String detect(String text) {
    if (text.trim().length < 10) {
      return 'neutral';
    }

    final cleaned = _preprocess(text);
    final scores = <String, int>{};

    for (final entry in _keywords.entries) {
      scores[entry.key] = 0;

      for (final word in cleaned) {
        if (entry.value.contains(word)) {
          scores[entry.key] = scores[entry.key]! + 1;
        }
      }
    }

    final maxScore =
    scores.values.isEmpty ? 0 : scores.values.reduce((a, b) => a > b ? a : b);

    if (maxScore == 0) {
      return 'neutral';
    }

    final topCategories = scores.entries
        .where((e) => e.value == maxScore)
        .map((e) => e.key)
        .toList();

    // Tie → neutral
    if (topCategories.length > 1) {
      return 'neutral';
    }

    return topCategories.first;
  }

  List<String> _preprocess(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toList();
  }
}
