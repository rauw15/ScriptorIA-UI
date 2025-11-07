/// Estadísticas del usuario
class UserStats {
  final int totalPractices;
  final int completedPractices;
  final int inProgressPractices;
  final int pendingPractices;
  final double averageScore;
  final int totalAchievements;

  const UserStats({
    required this.totalPractices,
    required this.completedPractices,
    required this.inProgressPractices,
    required this.pendingPractices,
    required this.averageScore,
    required this.totalAchievements,
  });

  /// Calcula el porcentaje de progreso
  double get progressPercentage {
    if (totalPractices == 0) return 0.0;
    return (completedPractices / totalPractices) * 100;
  }

  /// Calcula el porcentaje de progreso redondeado
  int get progressPercentageRounded {
    return progressPercentage.round();
  }
}

