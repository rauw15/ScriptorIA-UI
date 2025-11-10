import '../../domain/repositories/history_repository.dart';
import '../../domain/entities/history_item.dart';
import '../../../practice/data/datasources/trace_service_datasource.dart';
import '../../../../core/network/api_client.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final TraceServiceDataSource traceServiceDataSource;

  HistoryRepositoryImpl({
    TraceServiceDataSource? traceServiceDataSource,
  }) : traceServiceDataSource = traceServiceDataSource ??
            TraceServiceDataSourceImpl(ApiClient());

  @override
  Future<List<HistoryItem>> getHistory() async {
    try {
      final practices = await traceServiceDataSource.getPracticeHistory();
      
      return practices
          .where((practice) => practice.puntuacionGeneral != null)
          .map((practice) {
            return HistoryItem(
              id: practice.practiceId,
              letter: practice.letraPlantilla,
              score: practice.puntuacionGeneral!,
              completedAt: practice.fechaCarga,
            );
          })
          .toList()
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    } catch (e) {
      throw Exception('Error al obtener el historial: ${e.toString()}');
    }
  }
}

