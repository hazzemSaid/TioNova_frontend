// features/quiz/data/repo/Quizrepoimp.dart
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/quiz/data/datasources/IRemoteQuizDataSource.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';
import 'package:tionova/features/quiz/data/models/UserQuizStatusModel.dart';
import 'package:tionova/features/quiz/domain/repo/Quizrepo.dart';

class QuizRepoImp implements QuizRepo {
  final IRemoteQuizDataSource remoteQuizDataSource;

  QuizRepoImp({required this.remoteQuizDataSource});

  @override
  Future<Either<Failure, QuizModel>> createQuiz({
    required String token,
    required String chapterId,
  }) async {
    return await remoteQuizDataSource.createQuiz(
      token: token,
      chapterId: chapterId,
    );
  }

  @override
  Future<Either<Failure, UserQuizStatusModel>> setuserquizstatus({
    required String token,
    required String quizId,
    required Map<String, dynamic> body,
    required String chapterId,
  }) {
    return remoteQuizDataSource.setuserquizstatus(
      token: token,
      quizId: quizId,
      body: body,
      chapterId: chapterId,
    );
  }

  @override
  Future<Either<Failure, UserQuizStatusModel>> gethistory({
    required String token,
    required String chapterId,
  }) {
    return remoteQuizDataSource.gethistory(token: token, chapterId: chapterId);
  }
}
