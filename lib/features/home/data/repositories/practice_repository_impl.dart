import '../../domain/entities/practice_item.dart';
import '../../domain/entities/user_stats.dart';

/// Repositorio simulado para gestionar prácticas
/// En producción, esto se conectaría con un backend real
class PracticeRepositoryImpl {
  // Datos simulados de letras - Todo empieza en cero (pending)
  static final List<PracticeItem> _letters = [
    const PracticeItem(
      id: 'letter_A',
      text: 'A',
      status: PracticeStatus.pending,
    ),
    const PracticeItem(
      id: 'letter_B',
      text: 'B',
      status: PracticeStatus.pending,
    ),
    const PracticeItem(
      id: 'letter_C',
      text: 'C',
      status: PracticeStatus.pending,
    ),
    const PracticeItem(
      id: 'letter_D',
      text: 'D',
      status: PracticeStatus.pending,
    ),
    const PracticeItem(
      id: 'letter_E',
      text: 'E',
      status: PracticeStatus.pending,
    ),
    const PracticeItem(
      id: 'letter_F',
      text: 'F',
      status: PracticeStatus.pending,
    ),
    const PracticeItem(
      id: 'letter_G',
      text: 'G',
      status: PracticeStatus.pending,
    ),
    const PracticeItem(
      id: 'letter_H',
      text: 'H',
      status: PracticeStatus.pending,
    ),
  ];

  // Datos simulados de números - Todo empieza en cero (pending)
  static final List<PracticeItem> _numbers = [
    const PracticeItem(
      id: 'number_1',
      text: '1',
      status: PracticeStatus.pending,
    ),
    const PracticeItem(
      id: 'number_2',
      text: '2',
      status: PracticeStatus.pending,
    ),
    const PracticeItem(
      id: 'number_3',
      text: '3',
      status: PracticeStatus.pending,
    ),
    const PracticeItem(
      id: 'number_4',
      text: '4',
      status: PracticeStatus.pending,
    ),
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
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));
    
    final allItems = [..._letters, ..._numbers];
    
    int completedCount = 0;
    int inProgressCount = 0;
    int pendingCount = 0;
    double totalScore = 0.0;
    int scoredItems = 0;

    for (final item in allItems) {
      switch (item.status) {
        case PracticeStatus.completed:
          // Solo contar como completada si tiene score >= 70
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
    
    // Calcular logros basados en prácticas completadas
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
    if (item.id.startsWith('letter_')) {
      final index = _letters.indexWhere((l) => l.id == item.id);
      if (index != -1) {
        _letters[index] = item;
      }
    } else if (item.id.startsWith('number_')) {
      final index = _numbers.indexWhere((n) => n.id == item.id);
      if (index != -1) {
        _numbers[index] = item;
      }
    }
  }
}

