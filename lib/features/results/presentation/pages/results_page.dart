import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/results_provider.dart';
import '../widgets/score_container.dart';
import '../widgets/metrics_section.dart';
import '../widgets/feedback_cards.dart';
import '../../../home/domain/entities/practice_item.dart';

class ResultsPage extends ConsumerWidget {
  final String imagePath;
  final String letter;

  const ResultsPage({
    super.key,
    required this.imagePath,
    required this.letter,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(
      resultsProvider(ResultsParams(imagePath: imagePath, letter: letter)),
    );

    return Scaffold(
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Crear un PracticeItem con la misma letra para practicar otra vez
                  final practiceItem = PracticeItem(
                    id: letter.toLowerCase(),
                    text: letter,
                    status: PracticeStatus.pending,
                  );
                  Navigator.of(context).pushNamed(
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
                  // TODO: Navegar a historial
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximamente: Ver Historial')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Ver Historial'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Regresar a la selección de práctica
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/practice-selection',
                (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Volver a Selección'),
          ),
        ),
      ],
    );
  }
}

