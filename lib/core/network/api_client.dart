import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/constants.dart';

/// Cliente HTTP para comunicarse con el API
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 180),
        receiveTimeout: const Duration(seconds: 180),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor para agregar el token de autenticación
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: _tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // No sobrescribir Content-Type si es FormData (multipart)
          if (options.data is FormData) {
            options.headers.remove('Content-Type');
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _secureStorage.delete(key: _tokenKey);
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Guarda el token de autenticación
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Guarda los datos del usuario
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  /// Obtiene los datos del usuario guardados
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
    } catch (e) {
    }
    return null;
  }

  /// Elimina los datos del usuario
  Future<void> deleteUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  /// Obtiene el token de autenticación
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Elimina el token de autenticación
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
    await deleteUserData();
  }

  /// Realiza una petición GET
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      // Si la path es una URL absoluta, usar un Dio temporal sin baseUrl
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return await _makeAbsoluteRequest('GET', path, queryParameters: queryParameters);
      }
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Realiza una petición POST
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      // Si la path es una URL absoluta, usar un Dio temporal sin baseUrl
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return await _makeAbsoluteRequest('POST', path, data: data, queryParameters: queryParameters);
      }
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Realiza una petición PUT
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      // Si la path es una URL absoluta, usar un Dio temporal sin baseUrl
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return await _makeAbsoluteRequest('PUT', path, data: data, queryParameters: queryParameters);
      }
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Realiza una petición DELETE
  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      // Si la path es una URL absoluta, usar un Dio temporal sin baseUrl
      if (path.startsWith('http://') || path.startsWith('https://')) {
        return await _makeAbsoluteRequest('DELETE', path, data: data, queryParameters: queryParameters);
      }
      return await _dio.delete(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Realiza una petición con URL absoluta (sin baseUrl)
  Future<Response> _makeAbsoluteRequest(
    String method,
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    print('[ApiClient] 🌐 _makeAbsoluteRequest: $method $url');
    
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 180),
        receiveTimeout: const Duration(seconds: 180),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    // Agregar interceptor para autenticación
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('[ApiClient] 📤 Request: ${options.method} ${options.uri}');
          final token = await _secureStorage.read(key: _tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print('[ApiClient] ✅ Token agregado al header');
          } else {
            print('[ApiClient] ⚠️ No hay token disponible');
          }
          // No sobrescribir Content-Type si es FormData (multipart)
          if (options.data is FormData) {
            options.headers.remove('Content-Type');
            print('[ApiClient] 📎 FormData detectado, Content-Type removido');
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          print('[ApiClient] ❌ Error: ${error.type}');
          print('[ApiClient] 📋 Status: ${error.response?.statusCode}');
          print('[ApiClient] 📋 Message: ${error.message}');
          print('[ApiClient] 📋 Response: ${error.response?.data}');
          if (error.response?.statusCode == 401) {
            await _secureStorage.delete(key: _tokenKey);
            print('[ApiClient] 🔐 Token eliminado por 401');
          }
          return handler.next(error);
        },
        onResponse: (response, handler) {
          print('[ApiClient] ✅ Response: ${response.statusCode} ${response.statusMessage}');
          return handler.next(response);
        },
      ),
    );

    switch (method.toUpperCase()) {
      case 'GET':
        return await dio.get(url, queryParameters: queryParameters);
      case 'POST':
        return await dio.post(url, data: data, queryParameters: queryParameters);
      case 'PUT':
        return await dio.put(url, data: data, queryParameters: queryParameters);
      case 'DELETE':
        return await dio.delete(url, data: data, queryParameters: queryParameters);
      default:
        throw Exception('Método HTTP no soportado: $method');
    }
  }

  /// Maneja los errores de Dio y los convierte en excepciones personalizadas
  Exception _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return Exception('Tiempo de espera agotado. Por favor, verifica tu conexión a internet.');
    }

    if (error.type == DioExceptionType.connectionError) {
      return Exception('Error de conexión. Por favor, verifica tu conexión a internet.');
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final responseData = error.response!.data;
      
      String message = 'Error del servidor';
      if (responseData is Map) {
        message = responseData['message'] ?? 
                 responseData['error'] ?? 
                 responseData['detail'] ??
                 (responseData['errors'] != null ? responseData['errors'].toString() : null) ??
                 responseData.toString();
      } else if (responseData != null) {
        message = responseData.toString();
      }

      switch (statusCode) {
        case 400:
          final detailMessage = responseData is Map 
              ? (responseData['detail'] ?? responseData['errors'] ?? message)
              : message;
          return Exception('Solicitud inválida: $detailMessage');
        case 401:
          return Exception('No autorizado. Por favor, inicia sesión nuevamente.');
        case 403:
          return Exception('Acceso denegado: $message');
        case 404:
          return Exception('Recurso no encontrado: $message');
        case 409:
          return Exception('Conflicto: $message');
        case 500:
          return Exception('Error del servidor. Por favor, intenta más tarde.');
        default:
          return Exception('Error: $message');
      }
    }

    return Exception('Error desconocido: ${error.message}');
  }
}

