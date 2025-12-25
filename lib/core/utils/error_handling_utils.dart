import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';

class ErrorHandlingUtils {
  /// Handles DioException errors and extracts error information from backend response
  /// Supports error format: { "success": false, "error": "Error description", "statusCode": 400 }
  static Either<Failure, T> handleDioError<T>(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        // Handle response with status code
        final response = error.response!;
        final data = response.data;

        // Handle backend error format: { "success": false, "error": "...", "statusCode": ... }
        if (data is Map<String, dynamic>) {
          // Check for the standard error format
          if (data['success'] == false) {
            final errorMessage = data['error']?.toString() ?? 
                                data['message']?.toString() ?? 
                                'Request failed';
            final statusCode = data['statusCode']?.toString() ?? 
                             response.statusCode?.toString();
            return Left(ServerFailure(errorMessage, statusCode));
          }

          // Handle error response with error field
          if (data.containsKey('error')) {
            final errorMessage = data['error'] is String 
                ? data['error'] as String
                : data['error'].toString();
            final statusCode = data['statusCode']?.toString() ?? 
                             response.statusCode?.toString();
            return Left(ServerFailure(errorMessage, statusCode));
          }

          // Handle error response with message field
          if (data.containsKey('message')) {
            final errorMessage = data['message'] as String;
            final statusCode = data['statusCode']?.toString() ?? 
                             response.statusCode?.toString();
            return Left(ServerFailure(errorMessage, statusCode));
          }
        }

        // Handle other error responses
        final statusCode = response.statusCode?.toString();
        return Left(
          ServerFailure(
            'Request failed with status: ${response.statusCode} - ${response.statusMessage}',
            statusCode,
          ),
        );
      } else {
        // Handle request errors (no response) - network/timeout errors
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          return Left(
            ServerFailure(
              'Connection timeout. Please check your internet connection.',
            ),
          );
        }

        if (error.type == DioExceptionType.connectionError) {
          return Left(
            ServerFailure(
              'Network error. Please check your internet connection.',
            ),
          );
        }

        // Handle request errors (no response)
        return Left(ServerFailure('Network error: ${error.message ?? "Unknown error"}'));
      }
    }

    // Handle other types of errors
    return Left(ServerFailure('Unexpected error: $error'));
  }

  /// Handles API response and extracts error information from backend response
  /// Supports error format: { "success": false, "error": "Error description", "statusCode": 400 }
  static Either<Failure, T> handleApiResponse<T>({
    required Response response,
    required T Function(dynamic) onSuccess,
  }) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      try {
        final data = response.data;
        
        // Check for error in successful status code response
        if (data is Map<String, dynamic>) {
          // Handle backend error format: { "success": false, "error": "...", "statusCode": ... }
          if (data['success'] == false) {
            final errorMessage = data['error']?.toString() ?? 
                                data['message']?.toString() ?? 
                                'Request failed';
            final statusCode = data['statusCode']?.toString() ?? 
                             response.statusCode?.toString();
            return Left(ServerFailure(errorMessage, statusCode));
          }

          // If success is true or not present, proceed with parsing
          return Right(onSuccess(data));
        }
        
        return Right(onSuccess(data));
      } catch (e) {
        return Left(ServerFailure('Failed to parse response: $e'));
      }
    } else {
      // Handle non-2xx status codes
      final data = response.data;
      
      if (data is Map<String, dynamic>) {
        // Handle backend error format: { "success": false, "error": "...", "statusCode": ... }
        if (data['success'] == false) {
          final errorMessage = data['error']?.toString() ?? 
                              data['message']?.toString() ?? 
                              'Request failed';
          final statusCode = data['statusCode']?.toString() ?? 
                           response.statusCode?.toString();
          return Left(ServerFailure(errorMessage, statusCode));
        }

        // Handle error field
        if (data.containsKey('error')) {
          final errorMessage = data['error'] is String 
              ? data['error'] as String
              : data['error'].toString();
          final statusCode = data['statusCode']?.toString() ?? 
                           response.statusCode?.toString();
          return Left(ServerFailure(errorMessage, statusCode));
        }

        // Handle message field
        if (data.containsKey('message')) {
          final errorMessage = data['message'] as String;
          final statusCode = data['statusCode']?.toString() ?? 
                           response.statusCode?.toString();
          return Left(ServerFailure(errorMessage, statusCode));
      }
      }
      
      final statusCode = response.statusCode?.toString();
      return Left(
        ServerFailure(
          'Request failed with status: ${response.statusCode} - ${response.statusMessage}',
          statusCode,
        ),
      );
    }
  }
}
