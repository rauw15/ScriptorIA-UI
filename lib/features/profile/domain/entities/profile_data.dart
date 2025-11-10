import '../../../home/domain/entities/user.dart';
import '../../../home/domain/entities/user_stats.dart';

/// Datos del perfil del usuario
class ProfileData {
  final User user;
  final UserStats stats;
  final List<Achievement> achievements;
  final List<WeeklyProgress> weeklyProgress;

  const ProfileData({
    required this.user,
    required this.stats,
    required this.achievements,
    required this.weeklyProgress,
  });
}

/// Logro del usuario
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
  });
}

/// Progreso semanal
class WeeklyProgress {
  final String day;
  final int practicesCount;

  const WeeklyProgress({
    required this.day,
    required this.practicesCount,
  });
}

