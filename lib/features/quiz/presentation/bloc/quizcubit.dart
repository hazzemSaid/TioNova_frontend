// features/quiz/presentation/bloc/quizcubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/quiz/domain/usecases/CreateQuizUseCase.dart';
import 'package:tionova/features/quiz/domain/usecases/GetHistoryUseCase.dart';
import 'package:tionova/features/quiz/domain/usecases/UserQuizStatusUseCase.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizstate.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit({
    required this.createQuizUseCase,
    required this.userQuizStatusUseCase,
    required this.getHistoryUseCase,
  }) : super(QuizInitial());
  final GetHistoryUseCase getHistoryUseCase;
  final CreateQuizUseCase createQuizUseCase;
  final UserQuizStatusUseCase userQuizStatusUseCase;
  void createQuiz({required String token, required String chapterId}) async {
    emit(CreateQuizLoading());
    final result = await createQuizUseCase.call(
      token: token,
      chapterId: chapterId,
    );
    result.fold(
      (failure) => emit(CreateQuizFailure(failure: failure)),
      (quiz) => emit(CreateQuizSuccess(quiz: quiz)),
    );
  }

  void setuserquizstatus({
    required String token,
    required String quizId,
    required Map<String, dynamic> body,
    required String chapterId,
  }) async {
    emit(UserQuizStatusLoading());
    final result = await userQuizStatusUseCase.call(
      token: token,
      quizId: quizId,
      body: body,
      chapterId: chapterId,
    );
    result.fold(
      (failure) => emit(UserQuizStatusFailure(failure: failure)),
      (status) => emit(UserQuizStatusSuccess(status: status)),
    );
  }

  void gethistory({required String token, required String chapterId}) async {
    emit(GetHistoryLoading());
    final result = await getHistoryUseCase.call(
      token: token,
      chapterId: chapterId,
    );
    result.fold(
      (failure) => emit(GetHistoryFailure(failure: failure)),
      (history) => emit(GetHistorySuccess(history: history)),
    );
  }
}
