// features/quiz/presentation/bloc/quizcubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/utils/safe_emit.dart';
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
  void createQuiz({required String chapterId}) async {
    safeEmit(CreateQuizLoading());
    final result = await createQuizUseCase.call(chapterId: chapterId);
    result.fold(
      (failure) => safeEmit(CreateQuizFailure(failure: failure)),
      (quiz) => safeEmit(CreateQuizSuccess(quiz: quiz)),
    );
  }

  void setuserquizstatus({
    required String quizId,
    required Map<String, dynamic> body,
    required String chapterId,
  }) async {
    safeEmit(UserQuizStatusLoading());
    final result = await userQuizStatusUseCase.call(
      quizId: quizId,
      body: body,
      chapterId: chapterId,
    );
    result.fold(
      (failure) => safeEmit(UserQuizStatusFailure(failure: failure)),
      (status) => safeEmit(UserQuizStatusSuccess(status: status)),
    );
  }

  void gethistory({required String chapterId}) async {
    safeEmit(GetHistoryLoading());
    final result = await getHistoryUseCase.call(chapterId: chapterId);
    result.fold(
      (failure) => safeEmit(GetHistoryFailure(failure: failure)),
      (history) => safeEmit(GetHistorySuccess(history: history)),
    );
  }
}
