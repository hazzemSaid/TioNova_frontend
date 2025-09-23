import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/quiz/data/datasources/IRemoteQuizDataSource.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';
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
}
