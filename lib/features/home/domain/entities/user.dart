/// Entidad de Usuario para la capa de home
/// Representa un usuario en la capa de dominio
class User {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
  });
}

