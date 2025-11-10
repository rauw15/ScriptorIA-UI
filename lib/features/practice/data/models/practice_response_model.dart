class PracticeResponseModel {
  final String practiceId;
  final String userId;
  final String estadoAnalisis;
  final String mensaje;

  PracticeResponseModel({
    required this.practiceId,
    required this.userId,
    required this.estadoAnalisis,
    required this.mensaje,
  });

  factory PracticeResponseModel.fromJson(Map<String, dynamic> json) {
    return PracticeResponseModel(
      practiceId: json['practice_id'] as String,
      userId: json['user_id'] as String,
      estadoAnalisis: json['estado_analisis'] as String,
      mensaje: json['mensaje'] as String,
    );
  }
}

