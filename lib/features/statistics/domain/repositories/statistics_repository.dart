import '../entities/statistics_data.dart';

/// Repositorio abstracto para estadísticas
abstract class StatisticsRepository {
  Future<StatisticsData> getStatisticsData();
}

