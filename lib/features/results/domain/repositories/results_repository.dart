import '../entities/analysis_result.dart';

abstract class ResultsRepository {
  Future<AnalysisResult> getAnalysisResult({
    required String imagePath,
    required String letter,
  });
}

