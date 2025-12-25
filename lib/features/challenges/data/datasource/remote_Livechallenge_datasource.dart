import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/core/utils/error_handling_utils.dart';
import 'package:tionova/features/challenges/data/model/challenge_code.dart';
import 'package:tionova/features/challenges/domain/repo/LiveChallenge_repo.dart';

class RemoteLiveChallengeDataSource implements LiveChallengeRepo {
  final Dio _dio;
  RemoteLiveChallengeDataSource({required Dio dio}) : _dio = dio;

  @override
  Future<Either<Failure, ChallengeCode>> createLiveChallenge({
    required String title,
    required String chapterId,
  }) async {
    try {
    final response = await _dio.post(
      "/live/challenges",
      data: {'title': title, 'chapterId': chapterId},
    );
      return ErrorHandlingUtils.handleApiResponse<ChallengeCode>(
        response: response,
        onSuccess: (data) => ChallengeCode.fromJson(data),
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, void>> disconnectFromLiveChallenge({
    required String challengeCode,
  }) async {
    try {
    final response = await _dio.post(
        "/live/challenges/disconnect",
      data: {'challengeCode': challengeCode},
    );
      return ErrorHandlingUtils.handleApiResponse<void>(
        response: response,
        onSuccess: (_) => null,
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, void>> joinLiveChallenge({
    required String challengeCode,
    bool isReconnection = false,
  }) async {
    try {
      print('DataSource - Joining challenge with code: $challengeCode');
      print('DataSource - Base URL: ${_dio.options.baseUrl}');
      print(
        'DataSource - Full URL: ${_dio.options.baseUrl}/live/challenges/join',
      );

      final response = await _dio.post(
        "/live/challenges/join",
        data: {"challengeCode": challengeCode},
      );

      print('DataSource - Join response status: ${response.statusCode}');
      print('DataSource - Join response data: ${response.data}');

      return ErrorHandlingUtils.handleApiResponse<void>(
        response: response,
        onSuccess: (_) => null,
      );
    } catch (e) {
      print('DataSource - Error during join: $e');
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, void>> startLiveChallenge({
    required String challengeCode,
  }) async {
    /*Start Challenge (Owner-only)

POST /api/v1/live/challenges/start

Body: { challengeCode: string }

Auth: required

Returns: { success, message, totalQuestions, currentIndex: 0 }

Behavior: sets meta.status = in-progress , current.index = 0 , saves startedAt , updates Mongo status. */
    try {
    final response = await _dio.post(
      "/live/challenges/start",
      data: {'challengeCode': challengeCode},
    );
      return ErrorHandlingUtils.handleApiResponse<void>(
        response: response,
        onSuccess: (_) => null,
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, void>> submitLiveAnswer({
    required String challengeCode,
    required String answer,
  }) async {
    /*API: POST /api/v1/live/challenges/answer

Body: { challengeCode: string, answer: string }

Auth: required

Returns: { success, message, isCorrect, currentIndex, rankings }

Behavior: writes to answers[currentIndex][userId] , increments score on correctness, recomputes rankings, mirrors answer in Mongo*/
    try {
      final response = await _dio.post(
        "/live/challenges/answer",
        data: {'challengeCode': challengeCode, 'answer': answer},
      );
      return ErrorHandlingUtils.handleApiResponse<void>(
        response: response,
        onSuccess: (_) => null,
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkAndAdvance({
    required String challengeCode,
  }) async {
    /*API: POST /api/v1/live/challenges/check-advance

Body: { challengeCode: string }

Auth: required

Returns: { needsAdvance, advanced, completed, timeRemaining, currentIndex }

Behavior: Checks if all players answered, advances to next question if needed*/
    try {
      final response = await _dio.post(
        "/live/challenges/check-advance",
        data: {'challengeCode': challengeCode},
      );
      return ErrorHandlingUtils.handleApiResponse<Map<String, dynamic>>(
        response: response,
        onSuccess: (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }
}
