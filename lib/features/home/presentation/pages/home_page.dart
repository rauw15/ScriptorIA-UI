import 'package:flutter/material.dart';
import '../../domain/entities/practice_item.dart';
import '../../domain/entities/user_stats.dart';
import '../../data/repositories/practice_repository_impl.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../widgets/home_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/section_header.dart';
import '../widgets/letter_card.dart';
import '../widgets/bottom_navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PracticeRepositoryImpl _repository = PracticeRepositoryImpl();
  final AuthRepositoryImpl _authRepository = AuthRepositoryImpl();
  
  bool _isLoading = true;
  String userName = 'Usuario';
  UserStats? _stats;
  List<PracticeItem> _letters = [];
  List<PracticeItem> _numbers = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          // Usar name si está disponible, sino username, sino email sin @
          userName = user.name?.isNotEmpty == true 
              ? user.name! 
              : (user.email.isNotEmpty 
                  ? user.email.split('@')[0] 
                  : 'Usuario');
        });
      }
    } catch (e) {
      // Si no hay usuario, mantener el nombre por defecto
      if (mounted) {
        setState(() {
          userName = 'Usuario';
        });
      }
    }
  }

  Future<void> _loadData() async {
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

      final letters = await _repository.getLetters();
      final numbers = await _repository.getNumbers();
      final stats = await _repository.getUserStats();

      if (mounted) {
        setState(() {
          _letters = letters;
          _numbers = numbers;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      final errorText = e.toString();
      // Si el error es de autenticación, redirigir al login.
      if (errorText.contains('Usuario no autenticado') ||
          errorText.contains('No autorizado') ||
          errorText.contains('401')) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  void _onNavItemTapped(int index) {
    if (index == _currentIndex) return; // Ya estamos en esa pantalla
    
    switch (index) {
      case 0:
        // Ya estamos en Home
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/statistics');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con saludo
                      HomeHeader(userName: userName),
                      const SizedBox(height: 25),
                      // Tarjetas de estadísticas
                      if (_stats != null) _buildStatsSection(),
                      const SizedBox(height: 30),
                      // Sección de Letras
                      SectionHeader(
                        title: 'Letras del Alfabeto',
                        showSeeAll: true,
                        onSeeAll: () {
                          Navigator.of(context).pushNamed('/all-letters');
                        },
                      ),
                      const SizedBox(height: 15),
                      _buildLettersGrid(),
                      const SizedBox(height: 30),
                      // Sección de Números
                      const SectionHeader(title: 'Números'),
                      const SizedBox(height: 15),
                      _buildNumbersGrid(),
                      const SizedBox(height: 20),
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

  Widget _buildStatsSection() {
    if (_stats == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.track_changes,
            value: _stats!.completedPractices.toString(),
            label: 'Prácticas',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.trending_up,
            value: '${_stats!.progressPercentageRounded}%',
            label: 'Progreso',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.emoji_events,
            value: _stats!.totalAchievements.toString(),
            label: 'Logros',
          ),
        ),
      ],
    );
  }

  Widget _buildLettersGrid() {
    if (_letters.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No hay letras disponibles'),
        ),
      );
    }

    // Mostrar solo un subconjunto (por ejemplo, 6 letras) en la pantalla
    // principal. La página de "Todas las letras" mostrará el listado completo.
    final displayLetters = _letters.length > 6 ? _letters.take(6).toList() : _letters;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: displayLetters.length,
      itemBuilder: (context, index) {
        final letter = displayLetters[index];
        return LetterCard(
          practiceItem: letter,
          onTap: () async {
            final result = await Navigator.of(context).pushNamed(
              '/practice',
              arguments: letter,
            );
            // Si se completó una práctica, recargar datos
            if (result == true) {
              _loadData();
            }
          },
        );
      },
    );
  }

  Widget _buildNumbersGrid() {
    if (_numbers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No hay números disponibles'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _numbers.length,
      itemBuilder: (context, index) {
        final number = _numbers[index];
        return LetterCard(
          practiceItem: number,
          onTap: () async {
            final result = await Navigator.of(context).pushNamed(
              '/practice',
              arguments: number,
            );
            // Si se completó una práctica, recargar datos
            if (result == true) {
              _loadData();
            }
          },
        );
      },
    );
  }
}

