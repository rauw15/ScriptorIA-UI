import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/practice_state.dart';
import '../../domain/usecases/analyze_handwriting_usecase.dart';
import '../../data/datasources/image_picker_datasource.dart';
import '../../data/datasources/camera_datasource.dart';
import '../../data/repositories/practice_repository_impl.dart';

class PracticeNotifier extends StateNotifier<PracticeState> {
  final AnalyzeHandwritingUseCase analyzeHandwritingUseCase;
  final ImagePickerDataSource imagePickerDataSource;
  final CameraDataSource cameraDataSource;

  PracticeNotifier({
    required this.analyzeHandwritingUseCase,
    required this.imagePickerDataSource,
    required this.cameraDataSource,
    required String letter,
  }) : super(PracticeState(letter: letter));

  Future<void> pickImageFromCamera() async {
    try {
      state = state.copyWith(status: PracticeStatus.loading);
      final imageFile = await imagePickerDataSource.pickImageFromCamera();
      state = state.copyWith(
        status: PracticeStatus.imageSelected,
        selectedImagePath: imageFile.path,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: PracticeStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      state = state.copyWith(status: PracticeStatus.loading);
      final imageFile = await imagePickerDataSource.pickImageFromGallery();
      state = state.copyWith(
        status: PracticeStatus.imageSelected,
        selectedImagePath: imageFile.path,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: PracticeStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> removeImage() async {
    state = state.copyWith(
      status: PracticeStatus.initial,
      selectedImagePath: null,
    );
  }

  Future<void> saveDrawing(String imagePath) async {
    state = state.copyWith(
      status: PracticeStatus.imageSelected,
      selectedImagePath: imagePath,
      errorMessage: null,
    );
  }

  Future<void> analyzeHandwriting() async {
    if (state.selectedImagePath == null) {
      state = state.copyWith(
        status: PracticeStatus.error,
        errorMessage: 'Por favor selecciona una imagen primero',
      );
      return;
    }

    try {
      state = state.copyWith(status: PracticeStatus.analyzing);
      await analyzeHandwritingUseCase(
        imagePath: state.selectedImagePath!,
        letter: state.letter,
      );
      state = state.copyWith(status: PracticeStatus.analysisComplete);
    } catch (e) {
      state = state.copyWith(
        status: PracticeStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// Providers
final imagePickerDataSourceProvider = Provider<ImagePickerDataSource>((ref) {
  return ImagePickerDataSourceImpl(ImagePicker());
});

final cameraDataSourceProvider = Provider<CameraDataSource>((ref) {
  return CameraDataSourceImpl();
});

final analyzeHandwritingUseCaseProvider = Provider<AnalyzeHandwritingUseCase>((ref) {
  // TODO: Inyectar desde AppConfig
  return AnalyzeHandwritingUseCase(PracticeRepositoryImpl());
});

final practiceProvider = StateNotifierProvider.family<PracticeNotifier, PracticeState, String>(
  (ref, letter) {
    return PracticeNotifier(
      analyzeHandwritingUseCase: ref.watch(analyzeHandwritingUseCaseProvider),
      imagePickerDataSource: ref.watch(imagePickerDataSourceProvider),
      cameraDataSource: ref.watch(cameraDataSourceProvider),
      letter: letter,
    );
  },
);

