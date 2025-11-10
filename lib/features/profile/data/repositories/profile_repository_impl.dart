import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile_data.dart';
import '../../../home/data/repositories/practice_repository_impl.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../home/domain/entities/user_stats.dart';

/// Repositorio de perfil que combina datos de auth y practice
class ProfileRepositoryImpl implements ProfileRepository {
  final PracticeRepositoryImpl _practiceRepository;
  final AuthRepositoryImpl _authRepository;

  ProfileRepositoryImpl({
    PracticeRepositoryImpl? practiceRepository,
    AuthRepositoryImpl? authRepository,
  })  : _practiceRepository = practiceRepository ?? PracticeRepositoryImpl(),
        _authRepository = authRepository ?? AuthRepositoryImpl();

  @override
  Future<ProfileData> getProfileData() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        throw Exception('Usuario no autenticado. Por favor, inicia sesión nuevamente.');
      }

      final stats = await _practiceRepository.getUserStats();
      final achievements = _generateAchievements(stats);
      final weeklyProgress = _generateWeeklyProgress();

      return ProfileData(
        user: user,
        stats: stats,
        achievements: achievements,
        weeklyProgress: weeklyProgress,
      );
    } catch (e) {
      if (e.toString().contains('Usuario no autenticado')) {
        rethrow;
      }
      throw Exception('Error al cargar datos del perfil: ${e.toString()}');
    }
  }

  List<Achievement> _generateAchievements(UserStats stats) {
    final achievements = <Achievement>[];

    // Logro: Primera Semana
    if (stats.completedPractices >= 7) {
      achievements.add(const Achievement(
        id: 'first_week',
        title: 'Primera Semana',
        description: 'Completa 7 prácticas en una semana',
        icon: 'trophy',
        isUnlocked: true,
      ));
    } else {
      achievements.add(const Achievement(
        id: 'first_week',
        title: 'Primera Semana',
        description: 'Completa 7 prácticas en una semana',
        icon: 'trophy',
        isUnlocked: false,
      ));
    }

    // Logro: 100 Prácticas
    if (stats.completedPractices >= 100) {
      achievements.add(const Achievement(
        id: '100_practices',
        title: '100 Prácticas',
        description: 'Completa 100 prácticas',
        icon: 'target',
        isUnlocked: true,
      ));
    } else {
      achievements.add(const Achievement(
        id: '100_practices',
        title: '100 Prácticas',
        description: 'Completa 100 prácticas',
        icon: 'target',
        isUnlocked: false,
      ));
    }

    // Logro: Puntuación 90+
    if (stats.averageScore >= 90) {
      achievements.add(const Achievement(
        id: 'score_90',
        title: 'Puntuación 90+',
        description: 'Mantén un promedio de 90 o más',
        icon: 'star',
        isUnlocked: true,
      ));
    } else {
      achievements.add(const Achievement(
        id: 'score_90',
        title: 'Puntuación 90+',
        description: 'Mantén un promedio de 90 o más',
        icon: 'star',
        isUnlocked: false,
      ));
    }

    // Logro: 365 Días
    if (stats.completedPractices >= 365) {
      achievements.add(const Achievement(
        id: '365_days',
        title: '365 Días',
        description: 'Completa una práctica cada día durante un año',
        icon: 'lock',
        isUnlocked: true,
      ));
    } else {
      achievements.add(const Achievement(
        id: '365_days',
        title: '365 Días',
        description: 'Completa una práctica cada día durante un año',
        icon: 'lock',
        isUnlocked: false,
      ));
    }

    return achievements;
  }

  List<WeeklyProgress> _generateWeeklyProgress() {
    // Simular progreso semanal
    return const [
      WeeklyProgress(day: 'L', practicesCount: 3),
      WeeklyProgress(day: 'M', practicesCount: 5),
      WeeklyProgress(day: 'M', practicesCount: 2),
      WeeklyProgress(day: 'J', practicesCount: 4),
      WeeklyProgress(day: 'V', practicesCount: 6),
      WeeklyProgress(day: 'S', practicesCount: 3),
      WeeklyProgress(day: 'D', practicesCount: 1),
    ];
  }
}

