import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/profile_data.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/weekly_progress.dart';
import '../widgets/achievements_grid.dart';
import '../../../home/presentation/widgets/bottom_navigation.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileRepositoryImpl _repository = ProfileRepositoryImpl();
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  int _currentIndex = 2;
  
  bool _isLoading = true;
  ProfileData? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar primero si el usuario está autenticado
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _profileData = null;
          });
          // Redirigir al login si no hay usuario autenticado
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
        return;
      }

      final data = await _repository.getProfileData();
      if (mounted) {
        setState(() {
          _profileData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Si el error es de autenticación, redirigir al login
        if (e.toString().contains('Usuario no autenticado') || 
            e.toString().contains('No autorizado')) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar perfil: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _authRepository.signOut();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cerrar sesión: $e')),
          );
        }
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
        Navigator.of(context).pushReplacementNamed('/statistics');
        break;
      case 2:
        // Ya estamos en Profile
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
        body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _profileData == null
                ? const Center(child: Text('No hay datos disponibles'))
                : RefreshIndicator(
                    onRefresh: _loadProfileData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header con título y configuración
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Mi perfil',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              IconButton(
                                icon: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.settings,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                onPressed: () {
                                  // TODO: Navegar a configuración
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Configuración próximamente'),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Header del perfil
                          ProfileHeader(profileData: _profileData!),
                          const SizedBox(height: 25),
                          
                          // Estadísticas
                          ProfileStats(stats: _profileData!.stats),
                          const SizedBox(height: 25),
                          
                          // Progreso semanal
                          WeeklyProgressSection(
                            weeklyProgress: _profileData!.weeklyProgress,
                          ),
                          const SizedBox(height: 25),
                          
                          // Logros recientes
                          const Text(
                            'Logros Recientes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 15),
                          AchievementsGrid(
                            achievements: _profileData!.achievements,
                          ),
                          const SizedBox(height: 25),
                          
                          // Botones de acción
                          _buildActionButtons(),
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Ver estadísticas completas
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/statistics');
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bar_chart, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Ver Estadísticas Completas',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Cerrar sesión
        OutlinedButton(
          onPressed: _handleLogout,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: AppColors.error),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Cerrar Sesión',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

