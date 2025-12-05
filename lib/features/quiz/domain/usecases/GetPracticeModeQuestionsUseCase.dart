import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/quiz/data/models/PracticeModeQuizModel.dart';
import 'package:tionova/features/quiz/domain/repo/Quizrepo.dart';

/// Use case for fetching practice mode questions
/// Calls the /api/v1/practicemode endpoint with chapterId
/// Returns 30 random questions with answers and explanations
class GetPracticeModeQuestionsUseCase {
  final QuizRepo quizRepo;

  GetPracticeModeQuestionsUseCase({required this.quizRepo});

  Future<Either<Failure, PracticeModeQuizModel>> call({
    required String chapterId,
  }) async {
    return await quizRepo.getPracticeModeQuestions(chapterId: chapterId);
  }
}
