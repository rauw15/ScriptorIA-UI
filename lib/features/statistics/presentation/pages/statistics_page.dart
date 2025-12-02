import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/statistics_data.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../widgets/statistics_summary.dart';
import '../widgets/progress_chart.dart';
import '../../../home/presentation/widgets/bottom_navigation.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final StatisticsRepositoryImpl _repository = StatisticsRepositoryImpl();
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  int _currentIndex = 1;
  
  bool _isLoading = true;
  StatisticsData? _statisticsData;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Verificar que el usuario siga autenticado
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
        return;
      }

      final data = await _repository.getStatisticsData();
      if (mounted) {
        setState(() {
          _statisticsData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      final errorText = e.toString();
      if (errorText.contains('Usuario no autenticado') ||
          errorText.contains('No autorizado') ||
          errorText.contains('401')) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar estadísticas: $e')),
        );
      }
    }
  }

  void _onNavItemTapped(int index) {
    if (index == _currentIndex) return;
    
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        // Ya estamos en Statistics
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          title: const Text('Estadísticas'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _statisticsData == null
                ? const Center(child: Text('No hay datos disponibles'))
                : RefreshIndicator(
                    onRefresh: _loadStatistics,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Resumen de estadísticas
                          StatisticsSummary(stats: _statisticsData!.stats),
                          const SizedBox(height: 25),
                          
                          // Gráfico de progreso
                          const Text(
                            'Progreso Semanal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 15),
                          ProgressChart(
                            dailyProgress: _statisticsData!.dailyProgress,
                          ),
                          const SizedBox(height: 25),
                          
                          // Prácticas por letra
                          const Text(
                            'Prácticas por Letra',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildPracticesByLetter(),
                        ],
                      ),
                    ),
                  ),
      ),
        bottomNavigationBar: BottomNavigation(
          currentIndex: _currentIndex,
          onTap: _onNavItemTapped,
        ),
      ),
    );
  }

  Widget _buildPracticesByLetter() {
    final practices = _statisticsData!.practicesByLetter;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: practices.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Letra ${entry.key}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  '${entry.value} prácticas',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

