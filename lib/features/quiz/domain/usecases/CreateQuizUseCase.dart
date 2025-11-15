import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';
import 'package:tionova/features/quiz/domain/repo/Quizrepo.dart';

class CreateQuizUseCase {
  final QuizRepo quizRepo;

  CreateQuizUseCase({required this.quizRepo});

  Future<Either<Failure, QuizModel>> call({required String chapterId}) async {
    return await quizRepo.createQuiz(chapterId: chapterId);
  }
}
