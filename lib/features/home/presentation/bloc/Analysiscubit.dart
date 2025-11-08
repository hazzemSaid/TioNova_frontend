import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/home/domain/usecases/analysisusecase.dart';
import 'package:tionova/features/home/presentation/bloc/Analysisstate.dart';

class AnalysisCubit extends Cubit<AnalysisState> {
  AnalysisCubit({required this.analysisUseCase}) : super(AnalysisInitial());
  final AnalysisUseCase analysisUseCase;

  void loadAnalysisData(String token) async {
    emit(AnalysisLoading());
    final result = await analysisUseCase.execute(token: token);
    result.fold(
      (failure) => emit(AnalysisError(message: failure.errMessage)),
      (data) => emit(AnalysisLoaded(analysisData: data)),
    );
  }
}
