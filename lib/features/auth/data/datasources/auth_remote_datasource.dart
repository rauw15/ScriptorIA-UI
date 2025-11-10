import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/constants.dart';
import '../models/user_model.dart';

/// Datasource remoto para operaciones de autenticación
abstract class AuthRemoteDataSource {
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required int age,
    required String entorno,
    required String nivelEducativo,
  });

  Future<UserModel> signInWithEmail(String email, String password);
  
  Future<UserModel> signInWithGoogle();
  
  Future<void> signOut();
  
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required int age,
    required String entorno,
    required String nivelEducativo,
  }) async {
    try {
      final requestData = {
        'username': username,
        'email': email,
        'password': password,
        'age': age,
        'entorno': entorno,
        'nivel_educativo': nivelEducativo,
      };
      
      final response = await apiClient.post(
        '${AppConstants.authEndpoint}/register',
        data: requestData,
      );

      final userData = {
        'id': response.data['user_id'] ?? response.data['id'],
        'email': response.data['email'] ?? email,
        'username': response.data['username'] ?? username,
        'name': response.data['username'] ?? username,
        'password': '',
        'createdAt': DateTime.now().toIso8601String(),
      };

      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409 || e.response?.statusCode == 400) {
        final responseData = e.response?.data;
        String message = 'El email o username ya está en uso';
        
        if (responseData is Map) {
          message = responseData['message'] ?? 
                   responseData['detail'] ??
                   (responseData['errors'] != null ? responseData['errors'].toString() : null) ??
                   message;
        } else if (responseData != null) {
          message = responseData.toString();
        }
        
        throw Exception(message);
      }
      if (e.response?.statusCode == 422) {
        final responseData = e.response?.data;
        String message = 'Datos inválidos o faltantes';
        
        if (responseData is Map) {
          message = responseData['message'] ?? 
                   responseData['detail'] ??
                   (responseData['errors'] != null ? responseData['errors'].toString() : null) ??
                   message;
        } else if (responseData != null) {
          message = responseData.toString();
        }
        
        throw Exception(message);
      }
      rethrow;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al registrar usuario: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final response = await apiClient.post(
        '${AppConstants.authEndpoint}/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final userData = response.data['user'] ?? response.data;
      final token = response.data['token'] ?? response.data['accessToken'];

      if (token != null) {
        await apiClient.saveToken(token);
      }

      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Email o contraseña incorrectos');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      }
      rethrow;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al iniciar sesión: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final response = await apiClient.post(
        '${AppConstants.authEndpoint}/google',
      );

      final userData = response.data['user'] ?? response.data;
      final token = response.data['token'] ?? response.data['accessToken'];

      if (token != null) {
        await apiClient.saveToken(token);
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al iniciar sesión con Google: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await apiClient.post('${AppConstants.authEndpoint}/logout');
    } catch (e) {
      // Ignorar errores del logout remoto
    } finally {
      await apiClient.deleteToken();
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await apiClient.getToken();
      if (token == null) {
        return null;
      }

      final response = await apiClient.get('${AppConstants.authEndpoint}/me');
      final userData = response.data['user'] ?? response.data;
      
      return UserModel.fromJson(userData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await apiClient.deleteToken();
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

