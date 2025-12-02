import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/practice_state.dart';
import '../../domain/usecases/analyze_handwriting_usecase.dart';
import '../../data/datasources/image_picker_datasource.dart';
import '../../data/datasources/camera_datasource.dart';
import '../../data/datasources/trace_service_datasource.dart';
import '../../data/repositories/practice_repository_impl.dart';
import '../../../../core/network/api_client.dart';

class PracticeNotifier extends StateNotifier<PracticeState> {
  final AnalyzeHandwritingUseCase analyzeHandwritingUseCase;
  final ImagePickerDataSource imagePickerDataSource;
  final CameraDataSource cameraDataSource;
  final TraceServiceDataSource traceServiceDataSource;

  PracticeNotifier({
    required this.analyzeHandwritingUseCase,
    required this.imagePickerDataSource,
    required this.cameraDataSource,
    required this.traceServiceDataSource,
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
      String errorMessage;
      if (e is ImagePickerException) {
        errorMessage = e.message;
      } else {
        errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('ImagePickerException: ', '');
      }
      
      if (errorMessage.contains('No se seleccionó ninguna imagen') ||
          errorMessage.contains('cancel') ||
          errorMessage.contains('Usuario canceló')) {
        state = state.copyWith(
          status: PracticeStatus.initial,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          status: PracticeStatus.error,
          errorMessage: errorMessage,
        );
      }
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
      String errorMessage;
      if (e is ImagePickerException) {
        errorMessage = e.message;
      } else {
        errorMessage = e.toString();
      }
      
      if (errorMessage.contains('No se seleccionó ninguna imagen') ||
          errorMessage.contains('cancel') ||
          errorMessage.contains('Usuario canceló')) {
        state = state.copyWith(
          status: PracticeStatus.initial,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          status: PracticeStatus.error,
          errorMessage: errorMessage,
        );
      }
    }
  }

  Future<void> removeImage() async {
    state = state.copyWith(
      status: PracticeStatus.initial,
      selectedImagePath: null,
    );
  }

  void setImageFromCanvas(String imagePath) {
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
      
      // 1. Subir la práctica al trace-service
      final practiceId = await analyzeHandwritingUseCase(
        imagePath: state.selectedImagePath!,
        letter: state.letter,
      );
      
      // 2. Actualizar el practiceId pero mantener status como "analyzing"
      state = state.copyWith(
        practiceId: practiceId,
        // NO cambiar a analysisComplete todavía
      );
      
      // 3. Hacer polling hasta que el análisis esté completo
      const maxAttempts = 60; // 2 minutos máximo (60 intentos × 2 segundos)
      const pollingInterval = Duration(seconds: 2);
      
      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        try {
          final practice = await traceServiceDataSource.getPracticeById(practiceId);
          
          if (practice.estadoAnalisis == 'completado') {
            // Análisis completo, ahora sí cambiar el estado
            state = state.copyWith(
              status: PracticeStatus.analysisComplete,
            );
            return; // Salir del método, el listener navegará a resultados
          }
          
          if (practice.estadoAnalisis == 'error') {
            throw Exception('Error al procesar el análisis en el servidor');
          }
          
          // Aún pendiente, esperar un poco más antes del siguiente intento
          if (attempt < maxAttempts - 1) {
            await Future.delayed(pollingInterval);
          }
        } catch (e) {
          // Si hay error al obtener la práctica, continuar intentando
          // (puede ser un error temporal de red)
          if (attempt < maxAttempts - 1) {
            await Future.delayed(pollingInterval);
          }
        }
      }
      
      // Si llegamos aquí, se agotó el tiempo de espera
      throw Exception('El análisis está tomando más tiempo del esperado. Por favor, verifica más tarde en tu historial.');
      
    } catch (e) {
      state = state.copyWith(
        status: PracticeStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final traceServiceDataSourceProvider = Provider<TraceServiceDataSource>((ref) {
  return TraceServiceDataSourceImpl(ref.watch(apiClientProvider));
});

final practiceRepositoryProvider = Provider<PracticeRepositoryImpl>((ref) {
  return PracticeRepositoryImpl(ref.watch(traceServiceDataSourceProvider));
});

final imagePickerDataSourceProvider = Provider<ImagePickerDataSource>((ref) {
  return ImagePickerDataSourceImpl(ImagePicker());
});

final cameraDataSourceProvider = Provider<CameraDataSource>((ref) {
  return CameraDataSourceImpl();
});

final analyzeHandwritingUseCaseProvider = Provider<AnalyzeHandwritingUseCase>((ref) {
  return AnalyzeHandwritingUseCase(ref.watch(practiceRepositoryProvider));
});

final practiceProvider = StateNotifierProvider.family<PracticeNotifier, PracticeState, String>(
  (ref, letter) {
    return PracticeNotifier(
      analyzeHandwritingUseCase: ref.watch(analyzeHandwritingUseCaseProvider),
      imagePickerDataSource: ref.watch(imagePickerDataSourceProvider),
      cameraDataSource: ref.watch(cameraDataSourceProvider),
      traceServiceDataSource: ref.watch(traceServiceDataSourceProvider),
      letter: letter,
    );
  },
);

