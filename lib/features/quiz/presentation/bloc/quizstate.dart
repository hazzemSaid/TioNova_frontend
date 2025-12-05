// features/quiz/presentation/bloc/quizstate.dart
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/quiz/data/models/PracticeModeQuizModel.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';
import 'package:tionova/features/quiz/data/models/UserQuizStatusModel.dart';

abstract class QuizState {}

class QuizInitial extends QuizState {}

class CreateQuizLoading extends QuizState {}

class CreateQuizSuccess extends QuizState {
  final QuizModel quiz;

  CreateQuizSuccess({required this.quiz});
}

class CreateQuizFailure extends QuizState {
  final Failure failure;

  CreateQuizFailure({required this.failure});
}

class UserQuizStatusLoading extends QuizState {}

class UserQuizStatusSuccess extends QuizState {
  final UserQuizStatusModel status;

  UserQuizStatusSuccess({required this.status});
}

class UserQuizStatusFailure extends QuizState {
  final Failure failure;

  UserQuizStatusFailure({required this.failure});
}

class GetHistoryLoading extends QuizState {}

class GetHistorySuccess extends QuizState {
  final UserQuizStatusModel history;

  GetHistorySuccess({required this.history});
}

class GetHistoryFailure extends QuizState {
  final Failure failure;

  GetHistoryFailure({required this.failure});
}

// Practice Mode States
class PracticeModeLoading extends QuizState {}

class PracticeModeReady extends QuizState {
  final PracticeModeQuizModel quiz;
  final int currentQuestionIndex;
  final int correctCount;

  PracticeModeReady({
    required this.quiz,
    required this.currentQuestionIndex,
    required this.correctCount,
  });
}

class PracticeModeAnswerSelected extends QuizState {
  final PracticeModeQuizModel quiz;
  final int currentQuestionIndex;
  final String selectedAnswer;
  final int correctCount;

  PracticeModeAnswerSelected({
    required this.quiz,
    required this.currentQuestionIndex,
    required this.selectedAnswer,
    required this.correctCount,
  });
}

class PracticeModeAnswerChecked extends QuizState {
  final PracticeModeQuizModel quiz;
  final int currentQuestionIndex;
  final String selectedAnswer;
  final bool isCorrect;
  final String correctAnswer;
  final String explanation;
  final int correctCount;

  PracticeModeAnswerChecked({
    required this.quiz,
    required this.currentQuestionIndex,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.correctAnswer,
    required this.explanation,
    required this.correctCount,
  });
}

class PracticeModeComplete extends QuizState {
  final int totalQuestions;
  final int correctCount;

  PracticeModeComplete({
    required this.totalQuestions,
    required this.correctCount,
  });
}

class PracticeModeFailure extends QuizState {
  final Failure failure;

  PracticeModeFailure({required this.failure});
}
