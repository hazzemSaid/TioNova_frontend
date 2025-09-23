import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/quiz/domain/usecases/CreateQuizUseCase.dart';
import 'package:tionova/features/quiz/presentation/bloc/quizstate.dart';

class QuizCubit extends Cubit<QuizState> {
  QuizCubit({required this.createQuizUseCase}) : super(QuizInitial());
  final CreateQuizUseCase createQuizUseCase;

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
}
