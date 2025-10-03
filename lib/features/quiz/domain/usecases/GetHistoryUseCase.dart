// features/quiz/domain/usecases/GetHistoryUseCase.dart
import 'package:tionova/features/quiz/domain/repo/Quizrepo.dart';

class GetHistoryUseCase {
  final QuizRepo quizrepo;
  GetHistoryUseCase({required this.quizrepo});
  Future call({required String token, required String chapterId}) async {
    return await quizrepo.gethistory(token: token, chapterId: chapterId);
  }
}
