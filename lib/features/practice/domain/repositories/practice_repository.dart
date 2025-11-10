abstract class PracticeRepository {
  Future<String> analyzeHandwriting({
    required String imagePath,
    required String letter,
  });
}

