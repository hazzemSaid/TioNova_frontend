import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

        // Log unexpected null data
        if (data == null) {
          debugPrint(
            '⚠️ [ErrorHandlingUtils] DioException response data is null',
          );
          return Left(
            ServerFailure(
              'Server returned no data. Status code: ${response.statusCode}',
              response.statusCode?.toString(),
            ),
          );
        }

        // Handle backend error format: { "success": false, "error": "...", "statusCode": ... }
        if (data is Map<String, dynamic>) {
          // Check for the standard error format
          if (data['success'] == false) {
            final errorMessage =
                data['error']?.toString() ??
                data['message']?.toString() ??
                'Request failed';
            final statusCode =
                data['statusCode']?.toString() ??
                response.statusCode?.toString();
            return Left(ServerFailure(errorMessage, statusCode));
          }

          // Handle error response with error field
          if (data.containsKey('error') && data['error'] != null) {
            final errorMessage = data['error'] is String
                ? data['error'] as String
                : data['error'].toString();
            final statusCode =
                data['statusCode']?.toString() ??
                response.statusCode?.toString();
            return Left(ServerFailure(errorMessage, statusCode));
          }

          // Handle error response with message field
          if (data.containsKey('message') && data['message'] != null) {
            final errorMessage = data['message'].toString();
            final statusCode =
                data['statusCode']?.toString() ??
                response.statusCode?.toString();
            return Left(ServerFailure(errorMessage, statusCode));
          }
        }

        // Handle other error responses
        final statusCode = response.statusCode?.toString();
        return Left(
          ServerFailure(
            'Request failed with status: ${response.statusCode} - ${response.statusMessage ?? "No status message"}',
            statusCode,
          ),
        );
      } else {
        // Handle request errors (no response) - network/timeout errors
        final errorType = error.type;
        if (errorType == DioExceptionType.connectionTimeout ||
            errorType == DioExceptionType.receiveTimeout ||
            errorType == DioExceptionType.sendTimeout) {
          return Left(
            ServerFailure(
              'Connection timeout. Please check your internet connection.',
            ),
          );
        }

        if (errorType == DioExceptionType.connectionError) {
          return Left(
            ServerFailure(
              'Network error. Please check your internet connection.',
            ),
          );
        }

        // Handle request errors (no response)
        return Left(
          ServerFailure('Network error: ${error.message ?? "Unknown error"}'),
        );
      }
    }

    // Handle other types of errors
    debugPrint(
      '⚠️ [ErrorHandlingUtils] Unexpected error type: ${error.runtimeType}',
    );
    return Left(
      ServerFailure(
        'Unexpected error: ${error?.toString() ?? "Unknown error"}',
      ),
    );
  }

  /// Handles API response and extracts error information from backend response
  /// Supports error format: { "success": false, "error": "Error description", "statusCode": 400 }
  static Either<Failure, T> handleApiResponse<T>({
    required Response response,
    required T Function(dynamic) onSuccess,
  }) {
    final statusCode = response.statusCode;

    if (statusCode != null && statusCode >= 200 && statusCode < 300) {
      try {
        final data = response.data;

        if (data == null) {
          debugPrint(
            '⚠️ [ErrorHandlingUtils] API success response data is null',
          );
          return Left(
            ServerFailure(
              'Server returned no data despite successful status code',
            ),
          );
        }

        // Check for error in successful status code response
        if (data is Map<String, dynamic>) {
          // Handle backend error format: { "success": false, "error": "...", "statusCode": ... }
          if (data['success'] == false) {
            final errorMessage =
                data['error']?.toString() ??
                data['message']?.toString() ??
                'Request failed';
            final errStatusCode =
                data['statusCode']?.toString() ?? statusCode.toString();
            return Left(ServerFailure(errorMessage, errStatusCode));
          }

          // If success is true or not present, proceed with parsing
          return Right(onSuccess(data));
        }

        return Right(onSuccess(data));
      } catch (e) {
        debugPrint('❌ [ErrorHandlingUtils] Failed to parse response: $e');
        return Left(ServerFailure('Failed to parse response: $e'));
      }
    } else {
      // Handle non-2xx status codes or null status code
      final data = response.data;

      if (data is Map<String, dynamic>) {
        // Handle backend error format: { "success": false, "error": "...", "statusCode": ... }
        if (data['success'] == false) {
          final errorMessage =
              data['error']?.toString() ??
              data['message']?.toString() ??
              'Request failed';
          final errStatusCode =
              data['statusCode']?.toString() ?? statusCode?.toString();
          return Left(ServerFailure(errorMessage, errStatusCode));
        }

        // Handle error field
        if (data.containsKey('error') && data['error'] != null) {
          final errorMessage = data['error'] is String
              ? data['error'] as String
              : data['error'].toString();
          final errStatusCode =
              data['statusCode']?.toString() ?? statusCode?.toString();
          return Left(ServerFailure(errorMessage, errStatusCode));
        }

        // Handle message field
        if (data.containsKey('message') && data['message'] != null) {
          final errorMessage = data['message'].toString();
          final errStatusCode =
              data['statusCode']?.toString() ?? statusCode?.toString();
          return Left(ServerFailure(errorMessage, errStatusCode));
        }
      }

      final errStatusCode = statusCode?.toString();
      return Left(
        ServerFailure(
          'Request failed with status: ${statusCode ?? "Unknown"} - ${response.statusMessage ?? "No status message"}',
          errStatusCode,
        ),
      );
    }
  }
}
