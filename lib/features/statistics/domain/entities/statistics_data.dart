import '../../../home/domain/entities/user_stats.dart';

/// Datos de estadísticas del usuario
class StatisticsData {
  final UserStats stats;
  final List<DailyProgress> dailyProgress;
  final Map<String, int> practicesByLetter;
  final Map<String, double> averageScoreByLetter;

  const StatisticsData({
    required this.stats,
    required this.dailyProgress,
    required this.practicesByLetter,
    required this.averageScoreByLetter,
  });
}

/// Progreso diario
class DailyProgress {
  final DateTime date;
  final int practicesCount;
  final double averageScore;

  const DailyProgress({
    required this.date,
    required this.practicesCount,
    required this.averageScore,
  });
}

