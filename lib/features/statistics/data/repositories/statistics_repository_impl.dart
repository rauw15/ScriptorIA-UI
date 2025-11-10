import '../../domain/repositories/statistics_repository.dart';
import '../../domain/entities/statistics_data.dart';
import '../../../home/data/repositories/practice_repository_impl.dart';
import '../../../practice/data/datasources/trace_service_datasource.dart';
import '../../../../core/network/api_client.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final PracticeRepositoryImpl _practiceRepository;
  final TraceServiceDataSource _traceServiceDataSource;

  StatisticsRepositoryImpl({
    PracticeRepositoryImpl? practiceRepository,
    TraceServiceDataSource? traceServiceDataSource,
  })  : _practiceRepository = practiceRepository ?? PracticeRepositoryImpl(),
        _traceServiceDataSource = traceServiceDataSource ??
            TraceServiceDataSourceImpl(ApiClient());

  @override
  Future<StatisticsData> getStatisticsData() async {
    final stats = await _practiceRepository.getUserStats();

    try {
      final history = await _traceServiceDataSource.getPracticeHistory();
      final practicesWithScore = history
          .where((p) => p.puntuacionGeneral != null)
          .toList();

      final dailyProgress = _calculateDailyProgress(practicesWithScore);
      final practicesByLetter = _calculatePracticesByLetter(practicesWithScore);
      final averageScoreByLetter = _calculateAverageScoreByLetter(practicesWithScore);

      return StatisticsData(
        stats: stats,
        dailyProgress: dailyProgress,
        practicesByLetter: practicesByLetter,
        averageScoreByLetter: averageScoreByLetter,
      );
    } catch (e) {
      return StatisticsData(
        stats: stats,
        dailyProgress: _generateEmptyDailyProgress(),
        practicesByLetter: {},
        averageScoreByLetter: {},
      );
    }
  }

  List<DailyProgress> _calculateDailyProgress(
      List<dynamic> practices) {
    final now = DateTime.now();
    final progress = <DailyProgress>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final dayPractices = practices.where((p) {
        final practiceDate = p.fechaCarga;
        return practiceDate.isAfter(dayStart) && practiceDate.isBefore(dayEnd);
      }).toList();

      final count = dayPractices.length;
      final average = count > 0
          ? dayPractices
                  .map((p) => p.puntuacionGeneral ?? 0)
                  .reduce((a, b) => a + b) /
              count
          : 0.0;

      progress.add(DailyProgress(
        date: date,
        practicesCount: count,
        averageScore: average,
      ));
    }

    return progress;
  }

  Map<String, int> _calculatePracticesByLetter(List<dynamic> practices) {
    final map = <String, int>{};
    for (final practice in practices) {
      final letter = practice.letraPlantilla;
      map[letter] = (map[letter] ?? 0) + 1;
    }
    return map;
  }

  Map<String, double> _calculateAverageScoreByLetter(List<dynamic> practices) {
    final letterScores = <String, List<int>>{};
    
    for (final practice in practices) {
      if (practice.puntuacionGeneral != null) {
        final letter = practice.letraPlantilla;
        letterScores.putIfAbsent(letter, () => []).add(practice.puntuacionGeneral!);
      }
    }

    final averages = <String, double>{};
    letterScores.forEach((letter, scores) {
      averages[letter] = scores.reduce((a, b) => a + b) / scores.length;
    });

    return averages;
  }

  List<DailyProgress> _generateEmptyDailyProgress() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DailyProgress(
        date: date,
        practicesCount: 0,
        averageScore: 0.0,
      );
    });
  }
}

