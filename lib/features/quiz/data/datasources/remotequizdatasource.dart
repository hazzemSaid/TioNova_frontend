import 'package:dio/dio.dart';
import 'package:either_dart/either.dart' show Either, Left;
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/quiz/data/datasources/IRemoteQuizDataSource.dart';
import 'package:tionova/features/quiz/data/models/QuizModel.dart';

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

      return response.data.map((quiz) => QuizModel.fromJson(quiz)).toList();
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
