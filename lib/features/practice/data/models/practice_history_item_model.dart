class PracticeHistoryItemModel {
  final String practiceId;
  final String letraPlantilla;
  final DateTime fechaCarga;
  final int? puntuacionGeneral;

  PracticeHistoryItemModel({
    required this.practiceId,
    required this.letraPlantilla,
    required this.fechaCarga,
    this.puntuacionGeneral,
  });

  factory PracticeHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return PracticeHistoryItemModel(
      practiceId: json['practice_id'] as String,
      letraPlantilla: json['letra_plantilla'] as String,
      fechaCarga: DateTime.parse(json['fecha_carga'] as String),
      puntuacionGeneral: json['puntuacion_general'] as int?,
    );
  }
}

