import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/preferences/data/models/PreferencesModel.dart';

abstract class PreferencesRemoteDataSource {
  Future<Either<Failure, PreferencesModel>> getPreferences();
  Future<Either<Failure, PreferencesModel>> updatePreferences(
    Map<String, dynamic> preferences,
  );
}

class PreferencesRemoteDataSourceImpl implements PreferencesRemoteDataSource {
  final Dio dio;
  PreferencesRemoteDataSourceImpl({required this.dio});

  @override
  Future<Either<Failure, PreferencesModel>> getPreferences() async {
    try {
      final response = await dio.get("/profile/preferences");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = response.data;
          if (data is Map<String, dynamic> && data['success'] == true) {
            return Right(PreferencesModel.fromJson(data['data']));
          } else {
            return Left(
              ServerFailure(
                data['message']?.toString() ?? 'Failed to load preferences',
              ),
            );
          }
        } catch (parseError) {
          return Left(ServerFailure('Failed to parse preferences data'));
        }
      } else {
        return Left(
          ServerFailure('Failed to load preferences: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      // Handle 404 specifically for new users
      if (e.response?.statusCode == 404) {
        return Left(ServerFailure('No preferences found', '404'));
      }

      // Parse error response from API
      if (e.response != null) {
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              'Failed to load preferences';

          return Left(ServerFailure(errorMessage.toString()));
        } catch (_) {
          return Left(
            ServerFailure('Failed to load preferences. Please try again.'),
          );
        }
      }

      // Handle network errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return Left(
          ServerFailure(
            'Connection timeout. Please check your internet connection.',
          ),
        );
      }

      if (e.type == DioExceptionType.unknown) {
        return Left(
          ServerFailure(
            'Network error. Please check your internet connection.',
          ),
        );
      }

      return Left(
        ServerFailure('An unexpected error occurred. Please try again.'),
      );
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PreferencesModel>> updatePreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      print('🌐 Remote: Sending PATCH request');
      final response = await dio.patch(
        "/profile/preferences",
        data: preferences,
      );
      print('🌐 Remote: Response status: ${response.statusCode}');
      print('🌐 Remote: Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = response.data;
          if (data is Map<String, dynamic> && data['success'] == true) {
            print('🌐 Remote: Parsing successful response');
            final model = PreferencesModel.fromJson(data['data']);
            print('🌐 Remote: Model parsed successfully: ${model.toJson()}');
            return Right(model);
          } else {
            print('❌ Remote: Response format error');
            return Left(
              ServerFailure(
                data['message']?.toString() ?? 'Failed to update preferences',
              ),
            );
          }
        } catch (parseError) {
          print('❌ Remote: Parsing error: $parseError');
          return Left(ServerFailure('Failed to parse preferences data'));
        }
      } else {
        print('❌ Remote: Bad status code: ${response.statusCode}');
        return Left(
          ServerFailure('Failed to update preferences: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      print('❌ Remote: DioException: ${e.message}');

      // Parse error response from API
      if (e.response != null) {
        try {
          final errorData = e.response!.data;
          final errorMessage =
              errorData['error'] ??
              errorData['message'] ??
              'Failed to update preferences';

          return Left(ServerFailure(errorMessage.toString()));
        } catch (_) {
          return Left(
            ServerFailure('Failed to update preferences. Please try again.'),
          );
        }
      }

      // Handle network errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return Left(
          ServerFailure(
            'Connection timeout. Please check your internet connection.',
          ),
        );
      }

      if (e.type == DioExceptionType.unknown) {
        return Left(
          ServerFailure(
            'Network error. Please check your internet connection.',
          ),
        );
      }

      return Left(
        ServerFailure('An unexpected error occurred. Please try again.'),
      );
    } catch (e) {
      print('❌ Remote: Unexpected error: $e');
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
