import 'package:flutter/material.dart';

import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../home/data/repositories/practice_repository_impl.dart';
import '../../../home/domain/entities/user_stats.dart';
import '../../../home/presentation/widgets/bottom_navigation.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  final PracticeRepositoryImpl _practiceRepository = PracticeRepositoryImpl();

  bool _isLoading = true;
  String _userName = 'Usuario';
  String _email = '';
  UserStats? _stats;
  int _currentIndex = 3;

  final List<_AchievementBadge> _achievements = const [
    _AchievementBadge(
      icon: '🏆',
      title: 'Primera semana',
      unlocked: true,
    ),
    _AchievementBadge(
      icon: '🎯',
      title: '100 prácticas',
      unlocked: true,
    ),
    _AchievementBadge(
      icon: '⭐',
      title: 'Puntuación 90+',
      unlocked: true,
    ),
    _AchievementBadge(
      icon: '🔒',
      title: '365 días activo',
      unlocked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authRepository.getCurrentUser();
      final stats = await _practiceRepository.getUserStats();

      if (!mounted) return;

      setState(() {
        _userName = user?.name ?? (user?.email.split('@').first ?? 'Usuario');
        _email = user?.email ?? 'Sin correo';
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo cargar tu perfil: $e')),
      );
    }
  }

  void _onNavItemTapped(int index) {
    if (_currentIndex == index) return;

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/practice-selection');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/progress');
        break;
      case 3:
        // Already on profile
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración próximamente')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildStatsGrid(),
                      const SizedBox(height: 24),
                      _buildWeeklyProgress(),
                      const SizedBox(height: 24),
                      _buildAchievements(),
                      const SizedBox(height: 24),
                      _buildActions(),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E0E4)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFF1c6b50),
            child: Text(
              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _email,
            style: const TextStyle(
              color: Color(0xFF6A5B5E),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🌟'),
                SizedBox(width: 8),
                Text(
                  'Estudiante avanzada',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = _stats;
    if (stats == null) return const SizedBox.shrink();

    Widget buildStat(String label, String value) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E0E4)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6A5B5E),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: [
        buildStat('Días activos', '156'),
        buildStat('Prácticas', stats.totalPractices.toString()),
        buildStat('Logros', stats.totalAchievements.toString()),
      ],
    );
  }

  Widget _buildWeeklyProgress() {
    final data = const [
      _WeeklyProgressPoint(label: 'L', value: 60),
      _WeeklyProgressPoint(label: 'M', value: 80),
      _WeeklyProgressPoint(label: 'M', value: 45),
      _WeeklyProgressPoint(label: 'J', value: 90),
      _WeeklyProgressPoint(label: 'V', value: 70),
      _WeeklyProgressPoint(label: 'S', value: 30),
      _WeeklyProgressPoint(label: 'D', value: 55),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E0E4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Progreso semanal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((point) {
                final normalized = point.value / 100;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 20,
                            height: 120 * normalized,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFF8d4a5b),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        point.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5C4A4D),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Logros recientes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _achievements
              .map(
                (achievement) => Container(
                  width: (MediaQuery.of(context).size.width - 64) / 2,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: achievement.unlocked
                        ? const Color(0xFFFFF0F2)
                        : const Color(0xFFF3F1F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: achievement.unlocked
                          ? const Color(0xFF8d4a5b)
                          : const Color(0xFFE0D6DA),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievement.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!achievement.unlocked) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'Bloqueado',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8A7C80),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.bar_chart),
          label: const Text('Ver estadísticas completas'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            await _authRepository.signOut();
            if (!mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8d4a5b),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            'Cerrar sesión',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _AchievementBadge {
  final String icon;
  final String title;
  final bool unlocked;

  const _AchievementBadge({
    required this.icon,
    required this.title,
    required this.unlocked,
  });
}

class _WeeklyProgressPoint {
  final String label;
  final double value;

  const _WeeklyProgressPoint({
    required this.label,
    required this.value,
  });
}

