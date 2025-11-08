import 'package:tionova/features/home/data/models/analysisModel.dart';

abstract class AnalysisState {}

class AnalysisInitial extends AnalysisState {}

class AnalysisLoading extends AnalysisState {}

class AnalysisLoaded extends AnalysisState {
  final Analysismodel analysisData;
  AnalysisLoaded({required this.analysisData});
}

class AnalysisError extends AnalysisState {
  final String message;
  AnalysisError({required this.message});
}
