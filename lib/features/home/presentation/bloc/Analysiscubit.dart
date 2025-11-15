import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/utils/safe_emit.dart';
import 'package:tionova/features/home/domain/usecases/analysisusecase.dart';
import 'package:tionova/features/home/presentation/bloc/Analysisstate.dart';

class AnalysisCubit extends Cubit<AnalysisState> {
  AnalysisCubit({required this.analysisUseCase}) : super(AnalysisInitial());
  final AnalysisUseCase analysisUseCase;

  void loadAnalysisData() async {
    safeEmit(AnalysisLoading());
    final result = await analysisUseCase.execute();
    result.fold(
      (failure) => safeEmit(AnalysisError(message: failure.errMessage)),
      (data) => safeEmit(AnalysisLoaded(analysisData: data)),
    );
  }
}
