import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../home/domain/entities/user.dart' as home_user;

/// Repositorio simulado de autenticación
/// En producción, esto se conectaría con un backend real
class AuthRepositoryImpl implements AuthRepository {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';

  /// Registra un nuevo usuario
  @override
  Future<home_user.User> register({
    required String email,
    required String password,
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Obtener usuarios existentes
    final usersJson = prefs.getString(_usersKey);
    final List<AppUser> users = usersJson != null
        ? (jsonDecode(usersJson) as List)
            .map((e) => AppUser.fromMap(e as Map<String, dynamic>))
            .toList()
        : [];

    // Verificar si el usuario ya existe
    if (users.any((u) => u.email.toLowerCase() == email.toLowerCase())) {
      throw Exception('El email ya está registrado');
    }

    // Validar email
    if (!_isValidEmail(email)) {
      throw Exception('El email no es válido');
    }

    // Validar contraseña
    if (password.length < 8) {
      throw Exception('La contraseña debe tener al menos 8 caracteres');
    }

    // Crear nuevo usuario
    final newUser = AppUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email.toLowerCase(),
      password: password, // En producción esto debería estar hasheado
      name: name,
      createdAt: DateTime.now(),
    );

    // Guardar usuario
    users.add(newUser);
    await prefs.setString(_usersKey, jsonEncode(users.map((u) => u.toMap()).toList()));

    // Guardar usuario actual (auto-login después de registro)
    await prefs.setString(_currentUserKey, jsonEncode(newUser.toMap()));

    // Convertir a User de home
    return home_user.User(
      id: newUser.id,
      email: newUser.email,
      name: newUser.name,
    );
  }

  /// Inicia sesión con email y contraseña
  @override
  Future<home_user.User> signInWithEmail(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Obtener usuarios registrados
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) {
      throw Exception('No hay usuarios registrados. Por favor regístrate primero.');
    }

    final List<AppUser> users = (jsonDecode(usersJson) as List)
        .map((e) => AppUser.fromMap(e as Map<String, dynamic>))
        .toList();

    // Buscar usuario
    final user = users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase() && u.password == password,
      orElse: () => throw Exception('Email o contraseña incorrectos'),
    );

    // Guardar usuario actual
    await prefs.setString(_currentUserKey, jsonEncode(user.toMap()));

    // Convertir a User de home
    return home_user.User(
      id: user.id,
      email: user.email,
      name: user.name,
    );
  }

  /// Inicia sesión con Google (simulado)
  @override
  Future<home_user.User> signInWithGoogle() async {
    // Simular delay
    await Future.delayed(const Duration(seconds: 1));
    
    // En producción, esto haría la autenticación real con Google
    throw Exception('Login con Google no implementado aún');
  }

  /// Cierra sesión
  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  /// Obtiene el usuario actual
  @override
  Future<home_user.User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    
    if (userJson == null) {
      return null;
    }

    final userMap = jsonDecode(userJson) as Map<String, dynamic>;
    final appUser = AppUser.fromMap(userMap);

    return home_user.User(
      id: appUser.id,
      email: appUser.email,
      name: appUser.name,
    );
  }

  /// Valida si un email es válido
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
