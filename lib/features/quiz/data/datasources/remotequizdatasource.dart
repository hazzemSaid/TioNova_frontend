// features/quiz/data/datasources/remotequizdatasource.dart
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart' show Either, Left, Right;
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/core/utils/error_handling_utils.dart';
import 'package:tionova/features/quiz/data/datasources/IRemoteQuizDataSource.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';
import 'package:tionova/features/quiz/data/models/UserQuizStatusModel.dart';

class RemoteQuizDataSource implements IRemoteQuizDataSource {
  final Dio dio;

  RemoteQuizDataSource({required this.dio});

  @override
  Future<Either<Failure, QuizModel>> createQuiz({
    required String token,
    required String chapterId,
  }) async {
    try {
      final body = {'chapterId': chapterId};
      final response = await dio.post(
        '/createquiz',
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return ErrorHandlingUtils.handleApiResponse<QuizModel>(
        response: response,
        onSuccess: (data) => QuizModel.fromJson(data),
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, UserQuizStatusModel>> setuserquizstatus({
    required String token,
    required String quizId,
    required Map<String, dynamic> body,
    required String chapterId,
  }) async {
    try {
      final fullBody = {...body, 'quizId': quizId, 'chapterId': chapterId};
      final response = await dio.post(
        '/setuserquizstatus',
        data: fullBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return ErrorHandlingUtils.handleApiResponse<UserQuizStatusModel>(
        response: response,
        onSuccess: (data) {
          // If the response already contains the UserQuizStatusModel structure
          if (data.containsKey('attempts') &&
              data.containsKey('overallStatus')) {
            return UserQuizStatusModel.fromJson(data);
          }

          // Handle the case where the response has a different structure
          final result = data['result'] as Map<String, dynamic>? ?? data;

          final answers = <Answer>[];
          final graded = (result['gradedAnswers'] as List?) ?? const [];

          for (final e in graded) {
            try {
              final m = Map<String, dynamic>.from(e as Map);
              final options = ((m['options'] as List?) ?? const [])
                  .map((o) => o?.toString() ?? '')
                  .toList()
                  .cast<String>();

              answers.add(
                Answer(
                  questionId: m['questionId']?.toString() ?? '',
                  question: (m['question'] ?? '').toString(),
                  options: options,
                  correctAnswer: (m['correctAnswer'] ?? '').toString(),
                  selectedOption: (m['selectedOption'] ?? '').toString(),
                  isCorrect: (m['isCorrect'] ?? false) as bool,
                  explanation: (m['explanation'] ?? '').toString().isEmpty
                      ? null
                      : (m['explanation'] ?? '').toString(),
                ),
              );
            } catch (e) {
              print('Error parsing answer: $e');
            }
          }

          final now = DateTime.now();
          final attempt = Attempt(
            startedAt: now,
            completedAt: now,
            totalQuestions: (result['totalQuestions'] ?? 0) as int,
            correct: (result['correct'] ?? 0) as int,
            degree: (result['score'] ?? 0) as int,
            state: (result['status'] ?? 'completed').toString(),
            answers: answers,
          );

          return UserQuizStatusModel(
            attempts: [attempt],
            overallStatus: (result['status'] ?? 'completed').toString(),
            overallScore: (result['score'] ?? 0) as int,
            totalAttempts: 1,
            bestScore: (result['score'] ?? 0) as int,
            averageScore: (result['score'] ?? 0) as int,
            passRate: (result['score'] ?? 0) >= 50 ? 100 : 0,
          );
        },
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, UserQuizStatusModel>> gethistory({
    required String token,
    required String chapterId,
  }) async {
    //  /quizhistory
    try {
      final response = await dio.post(
        '/quizhistory',
        data: {'chapterId': chapterId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print(data);
        // adapt to expected shape: might be { success, message, history: {...} }
        final historyJson = (data['history'] as Map?) != null
            ? Map<String, dynamic>.from(data['history'] as Map)
            : Map<String, dynamic>.from(data as Map);
        final attemptsJson = (historyJson['attempts'] as List?) ?? const [];
        final attempts = attemptsJson
            .map((e) => Attempt.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        final statusModel = UserQuizStatusModel(
          attempts: attempts,
          overallStatus: (historyJson['overallStatus'] ?? '').toString(),
          overallScore: (historyJson['overallScore'] ?? 0) as int,
          totalAttempts:
              (historyJson['totalAttempts'] ?? attempts.length) as int,
          bestScore: (historyJson['bestScore'] ?? 0) as int,
          averageScore: (historyJson['averageScore'] ?? 0) as int,
          passRate: (historyJson['passRate'] ?? 0) as int,
        );
        return Right(statusModel);
      } else {
        return Left(ServerFailure('Failed to fetch quiz history'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
