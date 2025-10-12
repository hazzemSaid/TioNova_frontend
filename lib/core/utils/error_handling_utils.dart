import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';

class ErrorHandlingUtils {
  static Either<Failure, T> handleDioError<T>(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        // Handle response with status code
        final response = error.response!;
        final data = response.data;

        // Handle error response with message
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return Left(ServerFailure(data['message'] as String));
        }

        // Handle other error responses
        return Left(
          ServerFailure(
            'Request failed with status: ${response.statusCode} - ${response.statusMessage}',
          ),
        );
      } else {
        // Handle request errors (no response)
        return Left(ServerFailure('Network error: ${error.message}'));
      }
    }

    // Handle other types of errors
    return Left(ServerFailure('Unexpected error: $error'));
  }

  static Either<Failure, T> handleApiResponse<T>({
    required Response response,
    required T Function(dynamic) onSuccess,
  }) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      try {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == false) {
          return Left(ServerFailure(data['message'] ?? 'Request failed'));
        }
        return Right(onSuccess(data));
      } catch (e) {
        return Left(ServerFailure('Failed to parse response: $e'));
      }
    } else {
      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return Left(ServerFailure(data['message'] as String));
      }
      return Left(
        ServerFailure(
          'Request failed with status: ${response.statusCode} - ${response.statusMessage}',
        ),
      );
    }
  }
}
