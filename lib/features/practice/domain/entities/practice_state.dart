import 'package:equatable/equatable.dart';

enum PracticeStatus {
  initial,
  loading,
  imageSelected,
  analyzing,
  analysisComplete,
  error,
}

class PracticeState extends Equatable {
  final PracticeStatus status;
  final String? selectedImagePath;
  final String letter;
  final String? errorMessage;
  final String? practiceId; // ID de la práctica en el trace-service

  const PracticeState({
    this.status = PracticeStatus.initial,
    this.selectedImagePath,
    required this.letter,
    this.errorMessage,
    this.practiceId,
  });

  PracticeState copyWith({
    PracticeStatus? status,
    String? selectedImagePath,
    String? letter,
    String? errorMessage,
    String? practiceId,
  }) {
    return PracticeState(
      status: status ?? this.status,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      letter: letter ?? this.letter,
      errorMessage: errorMessage ?? this.errorMessage,
      practiceId: practiceId ?? this.practiceId,
    );
  }

  @override
  List<Object?> get props => [status, selectedImagePath, letter, errorMessage, practiceId];
}

