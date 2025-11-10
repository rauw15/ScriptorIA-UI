import '../repositories/practice_repository.dart';

class AnalyzeHandwritingUseCase {
  final PracticeRepository repository;

  AnalyzeHandwritingUseCase(this.repository);

  Future<String> call({
    required String imagePath,
    required String letter,
  }) async {
    return await repository.analyzeHandwriting(
      imagePath: imagePath,
      letter: letter,
    );
  }
}

