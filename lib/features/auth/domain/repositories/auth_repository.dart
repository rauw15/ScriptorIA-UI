import '../../../home/domain/entities/user.dart' as home_user;

/// Repositorio de autenticación
/// Define los contratos para las operaciones de autenticación
abstract class AuthRepository {
  Future<home_user.User> signInWithEmail(String email, String password);
  Future<home_user.User> signInWithGoogle();
  Future<void> signOut();
  Future<home_user.User?> getCurrentUser();
  
  /// Registra un nuevo usuario
  Future<home_user.User> register({
    required String email,
    required String password,
    String? name,
    required String username,
    required int age,
    required String entorno,
    required String nivelEducativo,
  });
}

