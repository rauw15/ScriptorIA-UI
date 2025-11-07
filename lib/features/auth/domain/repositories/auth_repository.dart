import '../entities/user.dart';

/// Repositorio de autenticación
/// Define los contratos para las operaciones de autenticación
abstract class AuthRepository {
  Future<User> signInWithEmail(String email, String password);
  Future<User> signInWithGoogle();
  Future<void> signOut();
  Future<User?> getCurrentUser();
}

