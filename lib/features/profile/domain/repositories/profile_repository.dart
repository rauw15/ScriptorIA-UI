import '../entities/profile_data.dart';

/// Repositorio abstracto para perfil
abstract class ProfileRepository {
  Future<ProfileData> getProfileData();
}

