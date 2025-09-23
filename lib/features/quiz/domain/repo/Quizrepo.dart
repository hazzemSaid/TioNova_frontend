import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';

abstract class QuizRepo {
  Future<Either<Failure, QuizModel>> createQuiz({
    required String token,
    required String chapterId,
  });
}
