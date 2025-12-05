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
      } else {
        return Left(
          ServerFailure('Failed to load preferences: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      // Handle 404 specifically for new users (Option 2)
      if (e.response?.statusCode == 404) {
        return Left(ServerFailure('No preferences found', '404'));
      }

      final errorMessage =
          e.response?.data?['message']?.toString() ??
          e.message?.toString() ??
          'Failed to load preferences';
      return Left(ServerFailure(errorMessage));
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
      } else {
        print('❌ Remote: Bad status code: ${response.statusCode}');
        return Left(
          ServerFailure('Failed to update preferences: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      print('❌ Remote: DioException: ${e.message}');
      final errorMessage =
          e.response?.data?['message']?.toString() ??
          e.message?.toString() ??
          'Failed to update preferences';
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      print('❌ Remote: Unexpected error: $e');
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
