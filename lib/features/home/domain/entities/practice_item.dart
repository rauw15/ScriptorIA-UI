/// Entidad que representa un item de práctica (letra o número)
class PracticeItem {
  final String id;
  final String text;
  final PracticeStatus status;
  final double? score; // Puntuación si está completada (0-100)
  final DateTime? completedAt;

  const PracticeItem({
    required this.id,
    required this.text,
    required this.status,
    this.score,
    this.completedAt,
  });

  /// Indica si el item está completado exitosamente
  /// Solo se considera completado si tiene un score >= 70
  bool get isCompletedSuccessfully {
    return status == PracticeStatus.completed && 
           score != null && 
           score! >= 70;
  }

  /// Indica si el item está en progreso
  bool get isInProgress {
    return status == PracticeStatus.inProgress;
  }

  /// Indica si el item está pendiente
  bool get isPending {
    return status == PracticeStatus.pending;
  }

  PracticeItem copyWith({
    String? id,
    String? text,
    PracticeStatus? status,
    double? score,
    DateTime? completedAt,
  }) {
    return PracticeItem(
      id: id ?? this.id,
      text: text ?? this.text,
      status: status ?? this.status,
      score: score ?? this.score,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Estado de una práctica
enum PracticeStatus {
  pending,      // No iniciada
  inProgress,   // En progreso (intentada pero no completada)
  completed,     // Completada (puede ser exitosa o no según el score)
}

