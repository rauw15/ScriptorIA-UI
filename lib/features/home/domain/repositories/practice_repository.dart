import '../entities/practice_item.dart';
import '../entities/user_stats.dart';

/// Repositorio abstracto para prácticas
abstract class PracticeRepository {
  Future<List<PracticeItem>> getLetters();
  Future<List<PracticeItem>> getNumbers();
  Future<UserStats> getUserStats();
  Future<void> updatePracticeItem(PracticeItem item);
}

