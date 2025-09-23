import 'package:tionova/core/errors/failure.dart';
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
