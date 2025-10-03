// features/quiz/domain/repo/Quizrepo.dart
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';
import 'package:tionova/features/quiz/data/models/UserQuizStatusModel.dart';

abstract class QuizRepo {
  Future<Either<Failure, QuizModel>> createQuiz({
    required String token,
    required String chapterId,
  });
  Future<Either<Failure, UserQuizStatusModel>> setuserquizstatus({
    required String token,
    required String quizId,
    required Map<String, dynamic> body,
    required String chapterId,
  });
  Future<Either<Failure, UserQuizStatusModel>> gethistory({
    required String token,
    required String chapterId,
  });
}
