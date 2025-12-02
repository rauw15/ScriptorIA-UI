import 'practice_detail_model.dart';

class PracticeResponseModel {
  final String practiceId;
  final String userId;
  final String letraPlantilla;
  final String urlImagen;
  final DateTime fechaCarga;
  final String estadoAnalisis;
  final AnalysisDataModel? analisis;

  PracticeResponseModel({
    required this.practiceId,
    required this.userId,
    required this.letraPlantilla,
    required this.urlImagen,
    required this.fechaCarga,
    required this.estadoAnalisis,
    this.analisis,
  });

  factory PracticeResponseModel.fromJson(Map<String, dynamic> json) {
    return PracticeResponseModel(
      practiceId: json['practice_id'] as String,
      userId: json['user_id'] as String,
      letraPlantilla: json['letra_plantilla'] as String,
      urlImagen: json['url_imagen'] as String,
      fechaCarga: DateTime.parse(json['fecha_carga'] as String),
      estadoAnalisis: json['estado_analisis'] as String,
      analisis: json['analisis'] != null
          ? AnalysisDataModel.fromJson(json['analisis'] as Map<String, dynamic>)
          : null,
    );
  }
}

