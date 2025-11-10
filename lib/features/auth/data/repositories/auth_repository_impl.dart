import '../../domain/repositories/auth_repository.dart';
import '../../../home/domain/entities/user.dart' as home_user;
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/network/api_client.dart';

/// Repositorio de autenticación que se conecta con el backend real
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({AuthRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ??
            AuthRemoteDataSourceImpl(apiClient: ApiClient());

  /// Registra un nuevo usuario
  @override
  Future<home_user.User> register({
    required String email,
    required String password,
    String? name,
    required String username,
    required int age,
    required String entorno,
    required String nivelEducativo,
  }) async {
    try {
      if (!_isValidEmail(email)) {
        throw Exception('El email no es válido');
      }

      if (password.length < 8) {
        throw Exception('La contraseña debe tener al menos 8 caracteres');
      }

      if (username.trim().isEmpty) {
        throw Exception('El nombre de usuario es requerido');
      }

      if (age < 1 || age > 120) {
        throw Exception('La edad debe ser válida');
      }

      final userModel = await remoteDataSource.register(
        username: username.trim(),
        email: email.trim(),
        password: password,
        age: age,
        entorno: entorno,
        nivelEducativo: nivelEducativo,
      );

      return home_user.User(
        id: userModel.id,
        email: userModel.email,
        name: userModel.name.isNotEmpty ? userModel.name : null,
        photoUrl: userModel.photoUrl,
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error al registrar usuario: ${e.toString()}');
    }
  }

  /// Inicia sesión con email y contraseña
  @override
  Future<home_user.User> signInWithEmail(String email, String password) async {
    try {
      final userModel = await remoteDataSource.signInWithEmail(email, password);

      return home_user.User(
        id: userModel.id,
        email: userModel.email,
        name: userModel.name.isNotEmpty ? userModel.name : null,
        photoUrl: userModel.photoUrl,
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error al iniciar sesión: ${e.toString()}');
    }
  }

  /// Inicia sesión con Google
  @override
  Future<home_user.User> signInWithGoogle() async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle();

      return home_user.User(
        id: userModel.id,
        email: userModel.email,
        name: userModel.name.isNotEmpty ? userModel.name : null,
        photoUrl: userModel.photoUrl,
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error al iniciar sesión con Google: ${e.toString()}');
    }
  }

  /// Cierra sesión
  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: ${e.toString()}');
    }
  }

  /// Obtiene el usuario actual
  @override
  Future<home_user.User?> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();

      if (userModel == null) {
        return null;
      }

      // Usar name si está disponible y no está vacío, sino null
      final userName = userModel.name.trim().isNotEmpty 
          ? userModel.name.trim() 
          : null;
      
      return home_user.User(
        id: userModel.id,
        email: userModel.email,
        name: userName,
        photoUrl: userModel.photoUrl,
      );
    } catch (e) {
      return null;
    }
  }

  /// Valida si un email es válido
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
