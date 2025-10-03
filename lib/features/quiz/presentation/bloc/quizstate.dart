// features/quiz/presentation/bloc/quizstate.dart
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/quiz/data/models/UserQuizStatusModel.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';

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
