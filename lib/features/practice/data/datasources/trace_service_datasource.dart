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
      print('[UI] 🚀 Iniciando uploadPractice');
      print('[UI] 📝 Letra: $letter');
      print('[UI] 📷 Image path: $imagePath');
      
      final token = await apiClient.getToken();
      if (token == null) {
        print('[UI] ❌ No hay token de autenticación');
        throw Exception('No estás autenticado. Por favor, inicia sesión antes de subir una práctica.');
      }
      print('[UI] ✅ Token encontrado (primeros 20 chars): ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
      
      // Validar que la letra sea un carácter válido (a-z, A-Z, 0-9)
      if (letter.length != 1) {
        throw Exception('La letra debe ser exactamente un carácter');
      }
      final validChars = RegExp(r'^[a-zA-Z0-9]$');
      if (!validChars.hasMatch(letter)) {
        throw Exception('La letra debe ser una letra (a-z, A-Z) o un número (0-9)');
      }
      
      final file = File(imagePath);
      if (!await file.exists()) {
        print('[UI] ❌ El archivo no existe: $imagePath');
        throw Exception('La imagen no existe');
      }
      
      final fileSize = await file.length();
      print('[UI] ✅ Archivo existe, tamaño: $fileSize bytes');

      // Endpoint correcto en FastAPI: POST /practices (sin barra final)
      final url = '${AppConstants.traceServiceBaseUrl}${AppConstants.practicesEndpoint}';
      print('[UI] 🌐 URL completa: $url');
      print('[UI] 📤 Preparando FormData...');

      final formData = FormData.fromMap({
        'letra': letter,
        'imagen': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      print('[UI] 📤 Enviando petición POST a: $url');
      final response = await apiClient.post(
        url,
        data: formData,
      );

      print('[UI] ✅ Respuesta recibida: Status ${response.statusCode}');
      print('[UI] 📊 Response data: ${response.data}');

      return PracticeResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('[UI] ❌ DioException capturada');
      print('[UI] 📋 Tipo: ${e.type}');
      print('[UI] 📋 Status: ${e.response?.statusCode}');
      print('[UI] 📋 Message: ${e.message}');
      print('[UI] 📋 Response data: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        print('[UI] ⏱️ Timeout error');
        throw Exception('Tiempo de espera agotado. Verifica que el servidor esté corriendo en ${AppConstants.traceServiceBaseUrl}');
      }
      
      if (e.type == DioExceptionType.connectionError) {
        print('[UI] 🔌 Connection error');
        throw Exception('No se pudo conectar al servidor. Verifica que:\n1. El trace-service esté corriendo en ${AppConstants.traceServiceBaseUrl}\n2. Tu dispositivo y el servidor estén en la misma red\n3. No haya firewall bloqueando');
      }
      
      if (e.response?.statusCode == 404) {
        final url = '${AppConstants.traceServiceBaseUrl}${AppConstants.practicesEndpoint}';
        throw Exception('Endpoint no encontrado (404). URL: $url\nVerifica que:\n1. El trace-service esté corriendo en ${AppConstants.traceServiceBaseUrl}\n2. El endpoint /practices exista\n3. Estés autenticado correctamente');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('No autorizado (401). Tu sesión ha expirado. Por favor, inicia sesión nuevamente.');
      }
      throw Exception('Error al subir la práctica: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('[UI] ❌ Exception general: $e');
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
      // Si el trace-service no está disponible, devolvemos historial vacío
      // para no bloquear la UI ni la experiencia del usuario.
      print('Error al obtener el historial (se devolverá lista vacía): $e');
      return [];
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

