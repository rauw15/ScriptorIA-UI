import 'dart:async';
import '../../domain/entities/analysis_result.dart';
import '../../domain/repositories/results_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../practice/data/datasources/trace_service_datasource.dart';
import '../../../practice/data/models/practice_detail_model.dart';

class ResultsRepositoryImpl implements ResultsRepository {
  final TraceServiceDataSource traceServiceDataSource;
  static const int maxPollingAttempts = 30;
  static const Duration pollingInterval = Duration(seconds: 2);

  ResultsRepositoryImpl(this.traceServiceDataSource);

  @override
  Future<AnalysisResult> getAnalysisResult({
    required String imagePath,
    required String letter,
  }) async {
    throw UnimplementedError('Use getAnalysisResultByPracticeId instead');
  }

  @override
  Future<AnalysisResult> getAnalysisResultByPracticeId(String practiceId) async {
    try {
      PracticeDetailModel? practice;
      int attempts = 0;

      while (attempts < maxPollingAttempts) {
        practice = await traceServiceDataSource.getPracticeById(practiceId);

        if (practice.estadoAnalisis == 'completado') {
          if (practice.analisis == null) {
            throw ServerFailure('El análisis está marcado como completado pero no hay datos');
          }
          return _convertToAnalysisResult(practice.analisis!);
        }

        if (practice.estadoAnalisis == 'error') {
          throw ServerFailure('Error al procesar el análisis');
        }

        await Future.delayed(pollingInterval);
        attempts++;
      }

      throw ServerFailure('Tiempo de espera agotado. El análisis está tomando más tiempo del esperado.');
    } catch (e) {
      if (e is ServerFailure) rethrow;
      throw ServerFailure('Error al obtener los resultados: ${e.toString()}');
    }
  }

  AnalysisResult _convertToAnalysisResult(AnalysisDataModel analisis) {
    return AnalysisResult(
      score: analisis.puntuacionGeneral,
      proportion: analisis.puntuacionProporcion.toDouble(),
      inclination: analisis.puntuacionInclinacion.toDouble(),
      spacing: analisis.puntuacionEspaciado.toDouble(),
      consistency: analisis.puntuacionConsistencia.toDouble(),
      strengths: analisis.fortalezas,
      improvements: analisis.areasMejora,
    );
  }
}

