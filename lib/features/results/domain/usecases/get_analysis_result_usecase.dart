import '../entities/analysis_result.dart';
import '../repositories/results_repository.dart';

class GetAnalysisResultUseCase {
  final ResultsRepository repository;

  GetAnalysisResultUseCase(this.repository);

  Future<AnalysisResult> call({
    required String imagePath,
    required String letter,
  }) async {
    return await repository.getAnalysisResult(
      imagePath: imagePath,
      letter: letter,
    );
  }

  /// Obtiene el resultado del análisis usando el practiceId
  Future<AnalysisResult> getByPracticeId(String practiceId) async {
    return await repository.getAnalysisResultByPracticeId(practiceId);
  }
}

