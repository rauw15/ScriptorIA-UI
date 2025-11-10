import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/results_provider.dart';
import '../widgets/score_container.dart';
import '../widgets/metrics_section.dart';
import '../widgets/feedback_cards.dart';
import '../../../home/domain/entities/practice_item.dart';

class ResultsPage extends ConsumerWidget {
  final String? imagePath;
  final String? letter;
  final String? practiceId;

  const ResultsPage({
    super.key,
    this.imagePath,
    this.letter,
    this.practiceId,
  });

  factory ResultsPage.fromImageAndLetter({
    required String imagePath,
    required String letter,
  }) {
    return ResultsPage(
      imagePath: imagePath,
      letter: letter,
    );
  }

  factory ResultsPage.fromPracticeId({
    required String practiceId,
  }) {
    return ResultsPage(practiceId: practiceId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(
      resultsProvider(
        practiceId != null
            ? ResultsParams.fromPracticeId(practiceId: practiceId!)
            : ResultsParams.fromImageAndLetter(
                imagePath: imagePath!,
                letter: letter!,
              ),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Resultados'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
              },
            ),
          ],
        ),
        body: resultsAsync.when(
        data: (result) => _buildContent(context, result),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildError(context, error.toString()),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Contenedor de puntuación
          ScoreContainer(score: result.score),
          const SizedBox(height: 30),
          
          // Sección de métricas
          MetricsSection(result: result),
          const SizedBox(height: 25),
          
          // Tarjetas de feedback
          FeedbackCards(
            strengths: result.strengths,
            improvements: result.improvements,
          ),
          const SizedBox(height: 25),
          
          // Botones de acción
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFba1a1a),
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar resultados',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              // Si tenemos letter, usarlo; si no, usar 'A' por defecto
              final letterToUse = letter ?? 'A';
              // Crear un PracticeItem temporal para navegar
              final practiceItem = PracticeItem(
                id: 'temp_$letterToUse',
                text: letterToUse,
                status: PracticeStatus.pending,
              );
              Navigator.of(context).pushReplacementNamed(
                '/practice',
                arguments: practiceItem,
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Practicar Otra'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/history');
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Ver Historial'),
          ),
        ),
      ],
    );
  }
}

