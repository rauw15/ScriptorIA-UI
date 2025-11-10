import '../entities/analysis_result.dart';

abstract class ResultsRepository {
  Future<AnalysisResult> getAnalysisResult({
    required String imagePath,
    required String letter,
  });
  
  /// Obtiene el resultado del análisis usando el practiceId
  Future<AnalysisResult> getAnalysisResultByPracticeId(String practiceId);
}

