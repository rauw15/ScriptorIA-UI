/// Item del historial de prácticas
class HistoryItem {
  final String id;
  final String letter;
  final int score;
  final DateTime completedAt;
  final String? imagePath;

  const HistoryItem({
    required this.id,
    required this.letter,
    required this.score,
    required this.completedAt,
    this.imagePath,
  });
}

