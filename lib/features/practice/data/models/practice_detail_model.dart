class PracticeDetailModel {
  final String practiceId;
  final String userId;
  final String letraPlantilla;
  final String? urlImagen;
  final DateTime fechaCarga;
  final String estadoAnalisis;
  final AnalysisDataModel? analisis;

  PracticeDetailModel({
    required this.practiceId,
    required this.userId,
    required this.letraPlantilla,
    this.urlImagen,
    required this.fechaCarga,
    required this.estadoAnalisis,
    this.analisis,
  });

  factory PracticeDetailModel.fromJson(Map<String, dynamic> json) {
    return PracticeDetailModel(
      practiceId: json['practice_id'] as String,
      userId: json['user_id'] as String,
      letraPlantilla: json['letra_plantilla'] as String,
      urlImagen: json['url_imagen'] as String?,
      fechaCarga: DateTime.parse(json['fecha_carga'] as String),
      estadoAnalisis: json['estado_analisis'] as String,
      analisis: json['analisis'] != null
          ? AnalysisDataModel.fromJson(json['analisis'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AnalysisDataModel {
  final int puntuacionGeneral;
  final int puntuacionProporcion;
  final int puntuacionInclinacion;
  final int puntuacionEspaciado;
  final int puntuacionConsistencia;
  final String fortalezas;
  final String areasMejora;

  AnalysisDataModel({
    required this.puntuacionGeneral,
    required this.puntuacionProporcion,
    required this.puntuacionInclinacion,
    required this.puntuacionEspaciado,
    required this.puntuacionConsistencia,
    required this.fortalezas,
    required this.areasMejora,
  });

  factory AnalysisDataModel.fromJson(Map<String, dynamic> json) {
    return AnalysisDataModel(
      puntuacionGeneral: json['puntuacion_general'] as int,
      puntuacionProporcion: json['puntuacion_proporcion'] as int,
      puntuacionInclinacion: json['puntuacion_inclinacion'] as int,
      puntuacionEspaciado: json['puntuacion_espaciado'] as int,
      puntuacionConsistencia: json['puntuacion_consistencia'] as int,
      fortalezas: json['fortalezas'] as String,
      areasMejora: json['areas_mejora'] as String,
    );
  }
}

