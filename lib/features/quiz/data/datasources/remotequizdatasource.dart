// features/quiz/data/datasources/remotequizdatasource.dart
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart' show Either, Left, Right;
import 'package:tionova/core/errors/failure.dart';
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

      if (response.data['success'] == true) {
        return Right(QuizModel.fromJson(response.data));
      } else {
        return Left(
          ServerFailure(response.data['message'] ?? 'Failed to create quiz'),
        );
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserQuizStatusModel>> setuserquizstatus({
    required String token,
    required String quizId,
    required Map<String, dynamic> body,
    required String chapterId,
  }) async {
    //setuserquizstatus
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
      if (response.statusCode == 200) {
        final data = response.data;
        print(data);
        // New API: parse directly from 'result'
        final result = data['result'] as Map<String, dynamic>?;
        if (result == null) {
          return Future.value(
            Left(ServerFailure('Missing result in response')),
          );
        }

        final totalQuestions = (result['totalQuestions'] ?? 0) as int;
        final correct = (result['correct'] ?? 0) as int;
        final score = (result['score'] ?? 0) as int;
        final status = (result['status'] ?? '').toString();
        final graded = (result['gradedAnswers'] as List?) ?? const [];

        final answers = graded.map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          final options = ((m['options'] as List?) ?? const [])
              .map((o) => o?.toString() ?? '')
              .toList()
              .cast<String>();
          return Answer(
            questionId: m['questionId']?.toString(),
            question: (m['question'] ?? '').toString(),
            options: options,
            correctAnswer: (m['correctAnswer'] ?? '').toString(),
            selectedOption: (m['selectedOption'] ?? '').toString(),
            isCorrect: (m['isCorrect'] ?? false) as bool,
            explanation: (m['explanation'] ?? '').toString().isEmpty
                ? null
                : (m['explanation'] ?? '').toString(),
          );
        }).toList();

        final attempt = Attempt(
          startedAt: DateTime.now(),
          completedAt: DateTime.now(),
          totalQuestions: totalQuestions,
          correct: correct,
          degree: score,
          state: status,
          answers: answers,
        );

        final statusModel = UserQuizStatusModel(
          attempts: [attempt],
          overallStatus: status,
          overallScore: score,
          totalAttempts: 1,
          bestScore: score,
          averageScore: score,
          passRate: 0,
        );
        return Right(statusModel);
      } else {
        return Future.value(
          Left(ServerFailure('Failed to set user quiz status')),
        );
      }
    } catch (e) {
      return Future.value(Left(ServerFailure(e.toString())));
    }
  }
}
