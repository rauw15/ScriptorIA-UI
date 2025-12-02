import '../../domain/entities/practice_item.dart';
import '../../domain/entities/user_stats.dart';
import '../../../practice/data/datasources/trace_service_datasource.dart';
import '../../../../core/network/api_client.dart';

class PracticeRepositoryImpl {
  final TraceServiceDataSource? _traceServiceDataSource;

  PracticeRepositoryImpl({
    TraceServiceDataSource? traceServiceDataSource,
  }) : _traceServiceDataSource = traceServiceDataSource ??
            TraceServiceDataSourceImpl(ApiClient());

  // Letras mayúsculas (A-Z)
  static final List<PracticeItem> _uppercaseLetters = List.generate(26, (index) {
    final letter = String.fromCharCode(65 + index); // A-Z
    return PracticeItem(
      id: 'letter_uppercase_$letter',
      text: letter,
      status: PracticeStatus.pending,
    );
  });

  // Letras minúsculas (a-z)
  static final List<PracticeItem> _lowercaseLetters = List.generate(26, (index) {
    final letter = String.fromCharCode(97 + index); // a-z
    return PracticeItem(
      id: 'letter_lowercase_$letter',
      text: letter,
      status: PracticeStatus.pending,
    );
  });

  // Letras especiales soportadas por el modelo (Ñ/ñ).
  // Otras como CH, LL no se añaden aún porque el backend
  // valida que letter_char tenga longitud 1.
  static final List<PracticeItem> _specialLetters = [
    const PracticeItem(
      id: 'letter_uppercase_Ñ',
      text: 'Ñ',
      status: PracticeStatus.pending,
    ),
    const PracticeItem(
      id: 'letter_lowercase_ñ',
      text: 'ñ',
      status: PracticeStatus.pending,
    ),
  ];

  // Números (0-9)
  static final List<PracticeItem> _numbers = List.generate(10, (index) {
    return PracticeItem(
      id: 'number_$index',
      text: index.toString(),
      status: PracticeStatus.pending,
    );
  });

  // Lista combinada de todas las letras (mayúsculas primero, luego minúsculas)
  static final List<PracticeItem> _letters = [
    ..._uppercaseLetters,
    ..._lowercaseLetters,
    ..._specialLetters,
  ];

  /// Obtiene todas las letras
  Future<List<PracticeItem>> getLetters() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_letters);
  }

  /// Obtiene todos los números
  Future<List<PracticeItem>> getNumbers() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_numbers);
  }

  /// Calcula las estadísticas del usuario
  Future<UserStats> getUserStats() async {
    try {
      if (_traceServiceDataSource != null) {
        final history = await _traceServiceDataSource.getPracticeHistory();
        final practicesWithScore = history
            .where((p) => p.puntuacionGeneral != null)
            .toList();

        final completedCount = practicesWithScore.length;
        final totalScore = practicesWithScore
            .map((p) => p.puntuacionGeneral!)
            .fold(0, (sum, score) => sum + score);
        final averageScore = completedCount > 0 ? totalScore / completedCount : 0.0;
        final achievements = _calculateAchievements(completedCount);

        return UserStats(
          totalPractices: _letters.length + _numbers.length,
          completedPractices: completedCount,
          inProgressPractices: 0,
          pendingPractices: (_letters.length + _numbers.length) - completedCount,
          averageScore: averageScore,
          totalAchievements: achievements,
        );
      }
    } catch (e) {
    }

    final allItems = [..._letters, ..._numbers];
    
    int completedCount = 0;
    int inProgressCount = 0;
    int pendingCount = 0;
    double totalScore = 0.0;
    int scoredItems = 0;

    for (final item in allItems) {
      switch (item.status) {
        case PracticeStatus.completed:
          if (item.isCompletedSuccessfully) {
            completedCount++;
            if (item.score != null) {
              totalScore += item.score!;
              scoredItems++;
            }
          } else {
            inProgressCount++;
          }
          break;
        case PracticeStatus.inProgress:
          inProgressCount++;
          break;
        case PracticeStatus.pending:
          pendingCount++;
          break;
      }
    }

    final averageScore = scoredItems > 0 ? totalScore / scoredItems : 0.0;
    final achievements = _calculateAchievements(completedCount);

    return UserStats(
      totalPractices: allItems.length,
      completedPractices: completedCount,
      inProgressPractices: inProgressCount,
      pendingPractices: pendingCount,
      averageScore: averageScore,
      totalAchievements: achievements,
    );
  }

  /// Calcula el número de logros basado en prácticas completadas
  int _calculateAchievements(int completedPractices) {
    if (completedPractices >= 20) return 12;
    if (completedPractices >= 15) return 10;
    if (completedPractices >= 10) return 8;
    if (completedPractices >= 5) return 5;
    if (completedPractices >= 2) return 2;
    return 0;
  }

  /// Actualiza el estado de un item de práctica
  Future<void> updatePracticeItem(PracticeItem item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Actualizar en la lista correspondiente
    if (item.id.startsWith('letter_uppercase_') || item.id.startsWith('letter_lowercase_')) {
      final index = _letters.indexWhere((l) => l.id == item.id);
      if (index != -1) {
        _letters[index] = item;
      }
      // También actualizar en la lista específica
      if (item.id.startsWith('letter_uppercase_')) {
        final uppercaseIndex = _uppercaseLetters.indexWhere((l) => l.id == item.id);
        if (uppercaseIndex != -1) {
          _uppercaseLetters[uppercaseIndex] = item;
        }
      } else {
        final lowercaseIndex = _lowercaseLetters.indexWhere((l) => l.id == item.id);
        if (lowercaseIndex != -1) {
          _lowercaseLetters[lowercaseIndex] = item;
        }
      }
    } else if (item.id.startsWith('number_')) {
      final index = _numbers.indexWhere((n) => n.id == item.id);
      if (index != -1) {
        _numbers[index] = item;
      }
    }
  }
}

