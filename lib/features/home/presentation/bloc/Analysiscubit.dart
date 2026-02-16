import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/home/domain/usecases/analysisusecase.dart';
import 'package:tionova/features/home/presentation/bloc/Analysisstate.dart';

class AnalysisCubit extends Cubit<AnalysisState> {
  AnalysisCubit({required this.analysisUseCase}) : super(AnalysisInitial());
  final AnalysisUseCase analysisUseCase;

  void loadAnalysisData() async {
    print('🔄 AnalysisCubit: Loading analysis data...');
    emit(AnalysisLoading());

    try {
      final result = await analysisUseCase.execute();
      result.fold(
        (failure) {
          print('❌ AnalysisCubit: Error - ${failure.errMessage}');
          emit(AnalysisError(message: failure.errMessage));
        },
        (data) {
          print('✅ AnalysisCubit: Data loaded successfully');
          emit(AnalysisLoaded(analysisData: data));
        },
      );
    } catch (e) {
      print('❌ AnalysisCubit: Exception - $e');
      emit(AnalysisError(message: e.toString()));
    }
  }
}
