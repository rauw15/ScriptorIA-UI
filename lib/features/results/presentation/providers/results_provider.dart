import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/usecases/get_analysis_result_usecase.dart';
import '../../data/repositories/results_repository_impl.dart';

class ResultsNotifier extends StateNotifier<AsyncValue<AnalysisResult>> {
  final GetAnalysisResultUseCase getAnalysisResultUseCase;
  final String imagePath;
  final String letter;

  ResultsNotifier({
    required this.getAnalysisResultUseCase,
    required this.imagePath,
    required this.letter,
  }) : super(const AsyncValue.loading()) {
    _loadResults();
  }

  Future<void> _loadResults() async {
    state = const AsyncValue.loading();
    try {
      final result = await getAnalysisResultUseCase(
        imagePath: imagePath,
        letter: letter,
      );
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadResults();
  }
}

final resultsProvider = StateNotifierProvider.family<
    ResultsNotifier,
    AsyncValue<AnalysisResult>,
    ResultsParams>((ref, params) {
  return ResultsNotifier(
    getAnalysisResultUseCase: GetAnalysisResultUseCase(ResultsRepositoryImpl()),
    imagePath: params.imagePath,
    letter: params.letter,
  );
});

class ResultsParams {
  final String imagePath;
  final String letter;

  ResultsParams({
    required this.imagePath,
    required this.letter,
  });
}

