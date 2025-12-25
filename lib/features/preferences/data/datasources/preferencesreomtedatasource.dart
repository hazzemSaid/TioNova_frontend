import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/core/utils/error_handling_utils.dart';
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

      return ErrorHandlingUtils.handleApiResponse<PreferencesModel>(
        response: response,
        onSuccess: (data) {
          if (data is Map<String, dynamic> && data['success'] == true) {
            return PreferencesModel.fromJson(data['data']);
          } else {
            throw Exception('Invalid response format');
          }
        },
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
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

      return ErrorHandlingUtils.handleApiResponse<PreferencesModel>(
        response: response,
        onSuccess: (data) {
          if (data is Map<String, dynamic> && data['success'] == true) {
            print('🌐 Remote: Parsing successful response');
            final model = PreferencesModel.fromJson(data['data']);
            print('🌐 Remote: Model parsed successfully: ${model.toJson()}');
            return model;
          } else {
            throw Exception('Invalid response format');
          }
        },
      );
    } catch (e) {
      print('❌ Remote: Error: $e');
      return ErrorHandlingUtils.handleDioError(e);
    }
  }
}
