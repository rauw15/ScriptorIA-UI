import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/domain/entities/practice_item.dart';
import '../../../home/data/repositories/practice_repository_impl.dart';

class PracticePage extends StatefulWidget {
  final PracticeItem practiceItem;

  const PracticePage({
    super.key,
    required this.practiceItem,
  });

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final PracticeRepositoryImpl _repository = PracticeRepositoryImpl();
  bool _isAnalyzing = false;
  bool _hasImage = false;
  double? _analysisScore;
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Practicar Letra "${widget.practiceItem.text}"'),
        backgroundColor: AppColors.surfaceContainerLow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta de referencia
            _buildReferenceCard(),
            const SizedBox(height: 25),
            // Sección de captura
            _buildCaptureSection(),
            const SizedBox(height: 25),
            // Botón de analizar
            if (_hasImage && !_isCompleted) _buildAnalyzeButton(),
            // Resultado del análisis
            if (_isAnalyzing) _buildAnalyzingProgress(),
            if (_isCompleted && _analysisScore != null) _buildResultCard(),
            const SizedBox(height: 25),
            // Consejos
            _buildTipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryContainer,
            AppColors.surfaceContainerLow,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Letra de Referencia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              widget.practiceItem.text,
              style: TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontFamily: 'Georgia',
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Traza la letra con cuidado y precisión',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tu Trazo',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: _hasImage ? null : _simulateCapture,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: _hasImage ? Colors.white : AppColors.surfaceContainerLow,
              border: Border.all(
                color: _hasImage ? AppColors.secondary : AppColors.outlineVariant,
                width: _hasImage ? 3 : 3,
                style: _hasImage ? BorderStyle.solid : BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: _hasImage
                ? Stack(
                    children: [
                      Center(
                        child: Text(
                          widget.practiceItem.text,
                          style: TextStyle(
                            fontSize: 120,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            fontFamily: 'Georgia',
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: AppColors.error),
                          onPressed: () {
                            setState(() {
                              _hasImage = false;
                              _isCompleted = false;
                              _analysisScore = null;
                            });
                          },
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 48,
                        color: AppColors.outline,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Toca para capturar o subir tu trazo',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (!_hasImage) ...[
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _simulateCapture,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Tomar Foto'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _simulateCapture,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galería'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAnalyzeButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _analyzeHandwriting,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.auto_awesome,
                  color: AppColors.onPrimary,
                ),
                SizedBox(width: 10),
                Text(
                  'Analizar Caligrafía',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzingProgress() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              LinearProgressIndicator(
                backgroundColor: AppColors.surfaceContainer,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 10),
              Text(
                'Analizando tu escritura... 🤖',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    final isSuccess = _analysisScore! >= 70;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSuccess ? AppColors.secondaryContainer : AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSuccess ? AppColors.secondary : AppColors.primary,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.info,
            size: 48,
            color: isSuccess ? AppColors.secondary : AppColors.primary,
          ),
          const SizedBox(height: 15),
          Text(
            isSuccess ? '¡Excelente Trabajo!' : 'Sigue Practicando',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isSuccess ? AppColors.onSecondaryContainer : AppColors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Puntuación: ${_analysisScore!.toInt()}/100',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isSuccess ? AppColors.onSecondaryContainer : AppColors.onPrimaryContainer,
            ),
          ),
          if (isSuccess) ...[
            const SizedBox(height: 15),
            Text(
              'Tu caligrafía está mejorando',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSecondaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: AppColors.onTertiaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                'Consejos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onTertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTip('Usa buena iluminación'),
          _buildTip('Escribe en papel blanco'),
          _buildTip('Mantén la cámara estable'),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _simulateCapture() {
    setState(() {
      _hasImage = true;
    });
  }

  Future<void> _analyzeHandwriting() async {
    setState(() {
      _isAnalyzing = true;
      _isCompleted = false;
    });

    // Simular análisis (2-3 segundos)
    await Future.delayed(const Duration(seconds: 2));

    // Generar score aleatorio entre 60-95
    final random = DateTime.now().millisecondsSinceEpoch;
    final score = 60 + (random % 36).toDouble();

    setState(() {
      _analysisScore = score;
      _isAnalyzing = false;
      _isCompleted = true;
    });

    // Actualizar el item en el repositorio
    final updatedItem = widget.practiceItem.copyWith(
      status: score >= 70 ? PracticeStatus.completed : PracticeStatus.inProgress,
      score: score,
      completedAt: score >= 70 ? DateTime.now() : null,
    );

    await _repository.updatePracticeItem(updatedItem);

    // Mostrar mensaje y navegar de vuelta después de un momento
    if (mounted) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pop(true); // Retornar true para indicar que se actualizó
        }
      });
    }
  }
}

