import 'dart:io';
import '../../domain/repositories/practice_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../datasources/trace_service_datasource.dart';
import '../models/practice_detail_model.dart';

class PracticeRepositoryImpl implements PracticeRepository {
  final TraceServiceDataSource traceServiceDataSource;

  PracticeRepositoryImpl(this.traceServiceDataSource);

  @override
  Future<String> analyzeHandwriting({
    required String imagePath,
    required String letter,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw const ServerException('La imagen no existe');
      }

      final response = await traceServiceDataSource.uploadPractice(
        imagePath: imagePath,
        letter: letter,
      );

      if (AppConstants.simulateAIAnalysis) {
        await traceServiceDataSource.updateAnalysis(
          practiceId: response.practiceId,
          analysis: AnalysisDataModel(
            puntuacionGeneral: 85,
            puntuacionProporcion: 90,
            puntuacionInclinacion: 82,
            puntuacionEspaciado: 78,
            puntuacionConsistencia: 88,
            fortalezas: 'Excelente proporción y altura de letra (análisis simulado)',
            areasMejora: 'Trabaja en mantener el espaciado uniforme (análisis simulado)',
          ),
        );
      }

      return response.practiceId;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Error al analizar la caligrafía: ${e.toString()}');
    }
  }
}

