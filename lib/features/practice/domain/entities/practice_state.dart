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

  const PracticeState({
    this.status = PracticeStatus.initial,
    this.selectedImagePath,
    required this.letter,
    this.errorMessage,
  });

  PracticeState copyWith({
    PracticeStatus? status,
    String? selectedImagePath,
    String? letter,
    String? errorMessage,
  }) {
    return PracticeState(
      status: status ?? this.status,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      letter: letter ?? this.letter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selectedImagePath, letter, errorMessage];
}

