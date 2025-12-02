import 'package:flutter/material.dart';

import '../../../home/data/repositories/practice_repository_impl.dart';
import '../../../home/domain/entities/user_stats.dart';
import '../../../home/presentation/widgets/bottom_navigation.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  final PracticeRepositoryImpl _repository = PracticeRepositoryImpl();
  bool _isLoading = true;
  UserStats? _stats;
  int _currentIndex = 2;

  final List<_WeeklyProgressPoint> _weeklyProgress = const [
    _WeeklyProgressPoint(label: 'L', value: 60),
    _WeeklyProgressPoint(label: 'M', value: 80),
    _WeeklyProgressPoint(label: 'M', value: 45),
    _WeeklyProgressPoint(label: 'J', value: 90),
    _WeeklyProgressPoint(label: 'V', value: 70),
    _WeeklyProgressPoint(label: 'S', value: 30),
    _WeeklyProgressPoint(label: 'D', value: 55),
  ];

  final List<_ProgressActivity> _activities = const [
    _ProgressActivity(
      title: 'Letra C completada',
      subtitle: 'Caligrafía impecable, sigue así',
      tag: 'Nueva puntuación: 92%',
      icon: Icons.check_circle,
      color: Color(0xFF1c6b50),
    ),
    _ProgressActivity(
      title: 'Número 7 revisado',
      subtitle: 'Analiza los trazos rectos',
      tag: 'Recomendación IA',
      icon: Icons.auto_fix_high,
      color: Color(0xFF8d4a5b),
    ),
    _ProgressActivity(
      title: 'Sesión pendiente',
      subtitle: 'Programa tu próxima práctica',
      tag: 'Recordatorio',
      icon: Icons.alarm,
      color: Color(0xFFf57c00),
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
      final stats = await _repository.getUserStats();

      if (!mounted) return;

      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar progreso: $e')),
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
        // Already here
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Progreso'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen General',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryCards(),
                      const SizedBox(height: 24),
                      _buildWeeklyProgressSection(),
                      const SizedBox(height: 24),
                      _buildPracticeDistribution(),
                      const SizedBox(height: 24),
                      _buildGoalsCard(),
                      const SizedBox(height: 24),
                      _buildActivitySection(),
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

  Widget _buildSummaryCards() {
    final stats = _stats;
    if (stats == null) return const SizedBox.shrink();

    final cards = [
      _SummaryCardData(
        label: 'Prácticas completadas',
        value: stats.completedPractices.toString(),
        icon: Icons.track_changes,
        color: const Color(0xFF1c6b50),
      ),
      _SummaryCardData(
        label: 'Promedio general',
        value: '${stats.progressPercentageRounded.toStringAsFixed(0)}%',
        icon: Icons.show_chart,
        color: const Color(0xFF8d4a5b),
      ),
      _SummaryCardData(
        label: 'Logros obtenidos',
        value: stats.totalAchievements.toString(),
        icon: Icons.emoji_events,
        color: const Color(0xFFf57c00),
      ),
    ];

    return Row(
      children: cards
          .map(
            (card) => Expanded(
              child: _SummaryCard(data: card),
            ),
          )
          .toList(),
    );
  }

  Widget _buildWeeklyProgressSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E0E4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso semanal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '+12% vs semana anterior',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weeklyProgress.map((point) {
                final normalized = point.value / 100.0;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 24,
                            height: 140 * normalized,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF8d4a5b),
                                  Color(0xFF1c6b50),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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

  Widget _buildPracticeDistribution() {
    final stats = _stats;
    if (stats == null) return const SizedBox.shrink();

    final total = stats.totalPractices == 0 ? 1 : stats.totalPractices;

    Widget buildChip(String label, int value, Color color) {
      final percentage = ((value / total) * 100).toStringAsFixed(0);
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$percentage%',
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribución de prácticas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: buildChip(
                'Completadas',
                stats.completedPractices,
                const Color(0xFF1c6b50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildChip(
                'En progreso',
                stats.inProgressPractices,
                const Color(0xFF8d4a5b),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        buildChip(
          'Pendientes',
          stats.pendingPractices,
          const Color(0xFF7A5D65),
        ),
      ],
    );
  }

  Widget _buildGoalsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1c6b50),
            Color(0xFF8d4a5b),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meta semanal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completa al menos 5 prácticas nuevas y mejora tu puntuación promedio en un 5%.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFF1c6b50),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Ver plan recomendado',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Actividad reciente',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Ver historial'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: _activities
              .map(
                (activity) => _ActivityCard(activity: activity),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SummaryCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _SummaryCard extends StatelessWidget {
  final _SummaryCardData data;

  const _SummaryCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E0E4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              data.icon,
              color: data.color,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: data.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: const TextStyle(
              color: Color(0xFF6A5B5E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyProgressPoint {
  final String label;
  final double value;

  const _WeeklyProgressPoint({
    required this.label,
    required this.value,
  });
}

class _ProgressActivity {
  final String title;
  final String subtitle;
  final String tag;
  final IconData icon;
  final Color color;

  const _ProgressActivity({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
    required this.color,
  });
}

class _ActivityCard extends StatelessWidget {
  final _ProgressActivity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E0E4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6A5B5E),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: activity.color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    activity.tag,
                    style: TextStyle(
                      color: activity.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

