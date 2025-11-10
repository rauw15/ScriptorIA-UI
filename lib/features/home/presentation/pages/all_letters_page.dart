import 'package:flutter/material.dart';
import '../../domain/entities/practice_item.dart';
import '../../data/repositories/practice_repository_impl.dart';
import '../widgets/letter_card.dart';
import '../widgets/bottom_navigation.dart';

class AllLettersPage extends StatefulWidget {
  const AllLettersPage({super.key});

  @override
  State<AllLettersPage> createState() => _AllLettersPageState();
}

class _AllLettersPageState extends State<AllLettersPage> {
  final PracticeRepositoryImpl _repository = PracticeRepositoryImpl();
  int _currentIndex = 0;
  
  bool _isLoading = true;
  List<PracticeItem> _letters = [];

  @override
  void initState() {
    super.initState();
    _loadLetters();
  }

  Future<void> _loadLetters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final letters = await _repository.getLetters();
      if (mounted) {
        setState(() {
          _letters = letters;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar letras: $e')),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Todas las Letras'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadLetters,
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
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
                        if (result == true) {
                          _loadLetters();
                        }
                      },
                    );
                  },
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}

