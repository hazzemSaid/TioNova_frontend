// features/quiz/data/datasources/IRemoteQuizDataSource.dart
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/quiz/data/models/PracticeModeQuizModel.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';
import 'package:tionova/features/quiz/data/models/UserQuizStatusModel.dart';

abstract class IRemoteQuizDataSource {
  Future<Either<Failure, QuizModel>> createQuiz({required String chapterId});
  Future<Either<Failure, UserQuizStatusModel>> setuserquizstatus({
    required String quizId,
    required Map<String, dynamic> body,
    required String chapterId,
  });
  Future<Either<Failure, UserQuizStatusModel>> gethistory({
    required String chapterId,
  });
  Future<Either<Failure, PracticeModeQuizModel>> getPracticeModeQuestions({
    required String chapterId,
  });
}
