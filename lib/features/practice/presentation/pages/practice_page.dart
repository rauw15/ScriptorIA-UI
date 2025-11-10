import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/practice_state.dart' as practice_domain;
import '../providers/practice_provider.dart';
import '../widgets/reference_letter_card.dart';
import '../widgets/capture_section.dart';
import '../widgets/tips_card.dart';
import '../../../home/domain/entities/practice_item.dart';

class PracticePage extends ConsumerStatefulWidget {
  final String letter;

  const PracticePage({
    super.key,
    required this.letter,
  });

  // Constructor alternativo para compatibilidad con código existente
  factory PracticePage.fromPracticeItem({
    required PracticeItem practiceItem,
  }) {
    return PracticePage(letter: practiceItem.text);
  }

  @override
  ConsumerState<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends ConsumerState<PracticePage> {
  @override
  Widget build(BuildContext context) {
    final practiceState = ref.watch(practiceProvider(widget.letter));
    final practiceNotifier = ref.read(practiceProvider(widget.letter).notifier);

    // Escuchar cambios de estado para navegar a resultados
    ref.listen<practice_domain.PracticeState>(
      practiceProvider(widget.letter),
      (previous, next) {
        if (next.status == practice_domain.PracticeStatus.analysisComplete &&
            next.selectedImagePath != null) {
          // Navegar a resultados usando Navigator
          Navigator.of(context).pushNamed(
            '/results',
            arguments: {
              'imagePath': next.selectedImagePath!,
              'letter': widget.letter,
            },
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Practicar Letra "${widget.letter}"'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta de referencia
            ReferenceLetterCard(letter: widget.letter),
            const SizedBox(height: 25),
            
            // Sección de captura
            CaptureSection(
              imagePath: practiceState.selectedImagePath,
              onTakePhoto: () => practiceNotifier.pickImageFromCamera(),
              onPickFromGallery: () => practiceNotifier.pickImageFromGallery(),
              onRemoveImage: () => practiceNotifier.removeImage(),
            ),
            const SizedBox(height: 25),
            
            // Botón de analizar
            _buildAnalyzeButton(practiceState, practiceNotifier),
            
            // Mostrar progreso si está analizando
            if (practiceState.status == practice_domain.PracticeStatus.analyzing)
              _buildAnalyzingProgress(),
            
            // Mostrar error si hay
            if (practiceState.errorMessage != null)
              _buildErrorWidget(practiceState.errorMessage!),
            
            const SizedBox(height: 25),
            
            // Tarjeta de consejos
            const TipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton(practice_domain.PracticeState state, PracticeNotifier notifier) {
    final isEnabled = state.selectedImagePath != null &&
        state.status != practice_domain.PracticeStatus.analyzing;

    return Container(
      decoration: BoxDecoration(
        gradient: isEnabled
            ? const LinearGradient(
                colors: [Color(0xFF8d4a5b), Color(0xFF1c6b50)],
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isEnabled
            ? () => notifier.analyzeHandwriting()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? null : const Color(0xFFfbeaec),
          foregroundColor: isEnabled ? Colors.white : const Color(0xFF847376),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 24),
            const SizedBox(width: 10),
            const Text(
              'Analizar Caligrafía',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzingProgress() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFfbeaec),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            backgroundColor: const Color(0xFFf5e4e6),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1c6b50)),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 10),
          const Text(
            'Analizando tu escritura... 🤖',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF514346),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFffdad6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFba1a1a), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFba1a1a)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF93000a),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

