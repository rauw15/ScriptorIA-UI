import 'package:flutter/material.dart';
import '../../../home/domain/entities/practice_item.dart';
import '../../../home/data/repositories/practice_repository_impl.dart';
import '../../../home/presentation/widgets/letter_card.dart';
import '../../../home/presentation/widgets/section_header.dart';
import '../../../home/presentation/widgets/bottom_navigation.dart';

class PracticeSelectionPage extends StatefulWidget {
  const PracticeSelectionPage({super.key});

  @override
  State<PracticeSelectionPage> createState() => _PracticeSelectionPageState();
}

class _PracticeSelectionPageState extends State<PracticeSelectionPage> {
  final PracticeRepositoryImpl _repository = PracticeRepositoryImpl();
  
  bool _isLoading = true;
  List<PracticeItem> _letters = [];
  List<PracticeItem> _numbers = [];
  int _currentIndex = 1; // Índice de práctica en el bottom nav

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
      final letters = await _repository.getLetters();
      final numbers = await _repository.getNumbers();

      if (mounted) {
        setState(() {
          _letters = letters;
          _numbers = numbers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  void _onNavItemTapped(int index) {
    if (_currentIndex == index) return;

    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        // Ya estamos aquí
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/progress');
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
        title: const Text('Seleccionar Práctica'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                      // Sección de Letras
                      const SectionHeader(
                        title: 'Letras del Alfabeto',
                        showSeeAll: false,
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

  Widget _buildLettersGrid() {
    if (_letters.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('No hay letras disponibles'),
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
      itemCount: _letters.length,
      itemBuilder: (context, index) {
        final letter = _letters[index];
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

