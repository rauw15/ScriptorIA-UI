import '../entities/history_item.dart';

/// Repositorio abstracto para historial
abstract class HistoryRepository {
  Future<List<HistoryItem>> getHistory();
}

