import 'package:equatable/equatable.dart';

class AnalysisResult extends Equatable {
  final int score; // 0-100
  final double proportion; // 0-100
  final double inclination; // 0-100
  final double spacing; // 0-100
  final double consistency; // 0-100
  final String strengths;
  final String improvements;

  const AnalysisResult({
    required this.score,
    required this.proportion,
    required this.inclination,
    required this.spacing,
    required this.consistency,
    required this.strengths,
    required this.improvements,
  });

  @override
  List<Object> get props => [
        score,
        proportion,
        inclination,
        spacing,
        consistency,
        strengths,
        improvements,
      ];
}

