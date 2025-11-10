import '../../domain/entities/analysis_result.dart';
import '../../domain/repositories/results_repository.dart';
import '../../../../core/error/failures.dart';

class ResultsRepositoryImpl implements ResultsRepository {
  @override
  Future<AnalysisResult> getAnalysisResult({
    required String imagePath,
    required String letter,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      return const AnalysisResult(
        score: 85,
        proportion: 90,
        inclination: 82,
        spacing: 78,
        consistency: 88,
        strengths: 'Excelente proporción y altura de letra',
        improvements: 'Trabaja en mantener el espaciado uniforme',
      );
    } catch (e) {
      throw ServerFailure('Error al obtener los resultados: $e');
    }
  }
}

