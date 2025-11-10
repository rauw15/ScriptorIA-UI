import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/constants.dart';
import '../models/practice_response_model.dart';
import '../models/practice_detail_model.dart';
import '../models/practice_history_item_model.dart';

abstract class TraceServiceDataSource {
  Future<PracticeResponseModel> uploadPractice({
    required String imagePath,
    required String letter,
  });
  
  Future<PracticeDetailModel> getPracticeById(String practiceId);
  
  Future<List<PracticeHistoryItemModel>> getPracticeHistory();
  
  Future<void> deletePractice(String practiceId);
  
  Future<bool> healthCheck();
  
  Future<void> updateAnalysis({
    required String practiceId,
    required AnalysisDataModel analysis,
  });
}

class TraceServiceDataSourceImpl implements TraceServiceDataSource {
  final ApiClient apiClient;

  TraceServiceDataSourceImpl(this.apiClient);

  @override
  Future<PracticeResponseModel> uploadPractice({
    required String imagePath,
    required String letter,
  }) async {
    try {
      final token = await apiClient.getToken();
      if (token == null) {
        throw Exception('No estás autenticado. Por favor, inicia sesión antes de subir una práctica.');
      }
      
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('La imagen no existe');
      }

      final formData = FormData.fromMap({
        'letra': letter,
        'imagen': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await apiClient.post(
        '${AppConstants.traceServiceBaseUrl}${AppConstants.practicesEndpoint}/',
        data: formData,
      );

      return PracticeResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        final url = '${AppConstants.traceServiceBaseUrl}${AppConstants.practicesEndpoint}/';
        throw Exception('Endpoint no encontrado (404). URL: $url\nVerifica que:\n1. El trace-service esté corriendo en ${AppConstants.traceServiceBaseUrl}\n2. El endpoint /practices/ exista\n3. Estés autenticado correctamente');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado (401). Tu sesión ha expirado. Por favor, inicia sesión nuevamente.');
      }
      throw Exception('Error al subir la práctica: ${e.response?.data ?? e.message}');
    } catch (e) {
      if (e.toString().contains('No estás autenticado')) {
        rethrow;
      }
      throw Exception('Error al subir la práctica: ${e.toString()}');
    }
  }

  @override
  Future<PracticeDetailModel> getPracticeById(String practiceId) async {
    try {
      final response = await apiClient.get(
        '${AppConstants.traceServiceBaseUrl}${AppConstants.practicesEndpoint}/$practiceId',
      );

      return PracticeDetailModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener la práctica: ${e.toString()}');
    }
  }

  @override
  Future<List<PracticeHistoryItemModel>> getPracticeHistory() async {
    try {
      final response = await apiClient.get(
        '${AppConstants.traceServiceBaseUrl}${AppConstants.practicesHistoryEndpoint}',
      );

      final List<dynamic> data = response.data;
      return data
          .map((json) => PracticeHistoryItemModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener el historial: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePractice(String practiceId) async {
    try {
      await apiClient.delete(
        '${AppConstants.traceServiceBaseUrl}${AppConstants.practicesEndpoint}/$practiceId',
      );
    } catch (e) {
      throw Exception('Error al eliminar la práctica: ${e.toString()}');
    }
  }

  @override
  Future<bool> healthCheck() async {
    try {
      final response = await apiClient.get(
        '${AppConstants.traceServiceBaseUrl}${AppConstants.healthEndpoint}',
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> updateAnalysis({
    required String practiceId,
    required AnalysisDataModel analysis,
  }) async {
    try {
      await apiClient.put(
        '${AppConstants.traceServiceBaseUrl}${AppConstants.practicesEndpoint}/$practiceId/analysis',
        data: {
          'puntuacion_general': analysis.puntuacionGeneral,
          'puntuacion_proporcion': analysis.puntuacionProporcion,
          'puntuacion_inclinacion': analysis.puntuacionInclinacion,
          'puntuacion_espaciado': analysis.puntuacionEspaciado,
          'puntuacion_consistencia': analysis.puntuacionConsistencia,
          'fortalezas': analysis.fortalezas,
          'areas_mejora': analysis.areasMejora,
        },
      );
    } catch (e) {
      throw Exception('Error al actualizar el análisis: ${e.toString()}');
    }
  }
}

