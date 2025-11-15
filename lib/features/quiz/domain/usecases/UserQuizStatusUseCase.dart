import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/quiz/data/models/UserQuizStatusModel.dart';
import 'package:tionova/features/quiz/domain/repo/Quizrepo.dart';

class UserQuizStatusUseCase {
  final QuizRepo repo;
  UserQuizStatusUseCase(this.repo);
  Future<Either<Failure, UserQuizStatusModel>> call({
    required String quizId,
    required Map<String, dynamic> body,
    required String chapterId,
  }) async {
    return await repo.setuserquizstatus(
      quizId: quizId,
      body: body,
      chapterId: chapterId,
    );
  }
}
