/// Entidad de usuario de la aplicación
class AppUser {
  final String id;
  final String email;
  final String password; // En producción esto debería estar hasheado
  final String? name;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.password,
    this.name,
    required this.createdAt,
  });

  /// Crea un usuario desde un mapa (útil para almacenamiento)
  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      name: map['name'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  /// Convierte el usuario a un mapa (útil para almacenamiento)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Copia el usuario con nuevos valores
  AppUser copyWith({
    String? id,
    String? email,
    String? password,
    String? name,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

