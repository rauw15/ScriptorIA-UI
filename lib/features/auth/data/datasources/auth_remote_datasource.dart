import 'package:dio/dio.dart';
import 'dart:convert';
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
      // Validar y limpiar la contraseña antes de enviarla
      final cleanPassword = password.trim();
      
      // Validar longitud mínima
      if (cleanPassword.length < 8) {
        throw Exception('La contraseña debe tener al menos 8 caracteres');
      }
      
      // Validar longitud máxima (72 bytes para bcrypt)
      final passwordBytes = utf8.encode(cleanPassword);
      if (passwordBytes.length > 72) {
        throw Exception('La contraseña no puede tener más de 72 bytes. Por favor, usa una contraseña más corta.');
      }
      
      final requestData = {
        'username': username.trim(),
        'email': email.trim(),
        'password': cleanPassword, // Usar la contraseña limpia
        'age': age,
        'entorno': entorno,
        'nivel_educativo': nivelEducativo,
      };
      
      final response = await apiClient.post(
        '${AppConstants.apiBaseUrl}${AppConstants.authEndpoint}/register',
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
        '${AppConstants.apiBaseUrl}${AppConstants.authEndpoint}/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // El backend ahora devuelve: { access_token, token_type, user: {...} }
      final token = response.data['access_token'] ?? 
                    response.data['token'] ?? 
                    response.data['accessToken'];

      // Obtener datos del usuario de la respuesta
      var userData = response.data['user'];
      
      // Si no hay user en la respuesta, intentar construir desde otros campos
      if (userData == null) {
        userData = {
          'id': response.data['user_id'] ?? response.data['id'],
          'email': email,
          'username': response.data['username'] ?? email.split('@')[0],
          'name': response.data['username'] ?? response.data['name'] ?? email.split('@')[0],
        };
      }

      if (token != null) {
        await apiClient.saveToken(token);
        // Guardar datos del usuario para uso offline
        await apiClient.saveUserData(userData);
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
    // TODO: Implementar cuando el backend tenga soporte para Google OAuth
    throw Exception('Inicio de sesión con Google no implementado aún');
  }

  @override
  Future<void> signOut() async {
    try {
      // El backend no tiene endpoint /logout, solo eliminamos el token localmente
      // En el futuro se puede implementar invalidación de tokens en el servidor
      await apiClient.deleteToken();
    } catch (e) {
      // Asegurarse de eliminar el token incluso si hay error
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

      try {
        final response = await apiClient.get('${AppConstants.apiBaseUrl}${AppConstants.authEndpoint}/me');
        // El backend devuelve UserDetailResponseDTO directamente
        final responseData = response.data;
        final userData = {
          'id': responseData['user_id'] ?? responseData['id'],
          'email': responseData['email'],
          'username': responseData['username'],
          'name': responseData['username'], // Usamos username como name
          'password': '',
          'createdAt': DateTime.now().toIso8601String(),
        };
        await apiClient.saveUserData(userData);
        return UserModel.fromJson(userData);
      } on DioException catch (e) {
        if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
          final savedUserData = await apiClient.getUserData();
          if (savedUserData != null) {
            return UserModel.fromJson(savedUserData);
          }
          await apiClient.deleteToken();
          return null;
        }
        final savedUserData = await apiClient.getUserData();
        if (savedUserData != null) {
          return UserModel.fromJson(savedUserData);
        }
        return null;
      } catch (e) {
        final savedUserData = await apiClient.getUserData();
        if (savedUserData != null) {
          return UserModel.fromJson(savedUserData);
        }
        return null;
      }
    } catch (e) {
      final savedUserData = await apiClient.getUserData();
      if (savedUserData != null) {
        return UserModel.fromJson(savedUserData);
      }
      return null;
    }
  }
}

