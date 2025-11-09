/// Modelo de usuario para la capa de datos
class UserModel {
  final String id;
  final String email;
  final String password;
  final String name;
  final String? photoUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

