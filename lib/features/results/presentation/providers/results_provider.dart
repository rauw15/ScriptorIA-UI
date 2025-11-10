import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/usecases/get_analysis_result_usecase.dart';
import '../../data/repositories/results_repository_impl.dart';
import '../../../practice/data/datasources/trace_service_datasource.dart';
import '../../../../core/network/api_client.dart';

class ResultsNotifier extends StateNotifier<AsyncValue<AnalysisResult>> {
  final GetAnalysisResultUseCase getAnalysisResultUseCase;
  final String? imagePath;
  final String? letter;
  final String? practiceId;

  ResultsNotifier({
    required this.getAnalysisResultUseCase,
    this.imagePath,
    this.letter,
    this.practiceId,
  }) : super(const AsyncValue.loading()) {
    _loadResults();
  }

  bool _isLoading = false;

  Future<void> _loadResults() async {
    if (_isLoading) {
      return;
    }
    
    _isLoading = true;
    state = const AsyncValue.loading();
    try {
      AnalysisResult result;
      if (practiceId != null) {
        result = await getAnalysisResultUseCase.getByPracticeId(practiceId!);
      } else if (imagePath != null && letter != null) {
        result = await getAnalysisResultUseCase(
          imagePath: imagePath!,
          letter: letter!,
        );
      } else {
        throw Exception('Se requiere practiceId o imagePath y letter');
      }
      
      state = AsyncValue.data(result);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refresh() async {
    await _loadResults();
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final traceServiceDataSourceProvider = Provider<TraceServiceDataSource>((ref) {
  return TraceServiceDataSourceImpl(ref.watch(apiClientProvider));
});

final resultsRepositoryProvider = Provider<ResultsRepositoryImpl>((ref) {
  return ResultsRepositoryImpl(ref.watch(traceServiceDataSourceProvider));
});

final getAnalysisResultUseCaseProvider = Provider<GetAnalysisResultUseCase>((ref) {
  return GetAnalysisResultUseCase(ref.watch(resultsRepositoryProvider));
});

final resultsProvider = StateNotifierProvider.family<
    ResultsNotifier,
    AsyncValue<AnalysisResult>,
    ResultsParams>((ref, params) {
  return ResultsNotifier(
    getAnalysisResultUseCase: ref.watch(getAnalysisResultUseCaseProvider),
    imagePath: params.imagePath,
    letter: params.letter,
    practiceId: params.practiceId,
  );
});

class ResultsParams {
  final String? imagePath;
  final String? letter;
  final String? practiceId;

  ResultsParams({
    this.imagePath,
    this.letter,
    this.practiceId,
  });

  ResultsParams.fromImageAndLetter({
    required String imagePath,
    required String letter,
  }) : imagePath = imagePath,
       letter = letter,
       practiceId = null;

  ResultsParams.fromPracticeId({
    required String practiceId,
  }) : practiceId = practiceId,
       imagePath = null,
       letter = null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResultsParams &&
        other.imagePath == imagePath &&
        other.letter == letter &&
        other.practiceId == practiceId;
  }

  @override
  int get hashCode => Object.hash(imagePath, letter, practiceId);
}

