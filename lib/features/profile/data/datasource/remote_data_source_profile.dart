import 'dart:io';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/core/utils/error_handling_utils.dart';

abstract class remoteDataSourceProfile {
  Future<Either<ServerFailure, Response>> fetchUserProfile();
  Future<Response> updateUserProfile(Map<String, dynamic> profileData);
}

class RemoteDataSourceProfileImpl implements remoteDataSourceProfile {
  final Dio dio;

  RemoteDataSourceProfileImpl({required this.dio});

  @override
  Future<Either<ServerFailure, Response>> fetchUserProfile() async {
    try {
      final response = await dio.get('/profile');
      final result = ErrorHandlingUtils.handleApiResponse<Response>(
        response: response,
        onSuccess: (_) => response,
      );
      
      // Convert Failure to ServerFailure for return type compatibility
      return result.fold(
        (failure) => Left(ServerFailure(failure.errMessage, failure.statusCode)),
        (response) => Right(response),
      );
    } catch (e) {
      final result = ErrorHandlingUtils.handleDioError<Response>(e);
      return result.fold(
        (failure) => Left(ServerFailure(failure.errMessage, failure.statusCode)),
        (_) => Left(ServerFailure('Unexpected error')),
      );
    }
  }

  @override
  Future<Response> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      // Check if we have a file to upload
      final File? imageFile = profileData['profilePicture'] as File?;
      Response response;

      if (imageFile != null) {
        // Use FormData for multipart file upload
        final formData = FormData.fromMap({
          'username': profileData['username'] ?? '',
          'universityCollege': profileData['universityCollege'] ?? '',
          'profilePicture': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
        });

        response = await dio.put('/profile', data: formData);
      } else {
        // No file, use regular JSON
        response = await dio.put(
          '/profile',
          data: {
            'username': profileData['username'] ?? '',
            'universityCollege': profileData['universityCollege'] ?? '',
          },
        );
      }

      // Use ErrorHandlingUtils to check response
      final result = ErrorHandlingUtils.handleApiResponse<Response>(
        response: response,
        onSuccess: (_) => response,
      );

      return result.fold(
        (failure) => throw ServerFailure(failure.errMessage, failure.statusCode),
        (response) => response,
      );
    } catch (e) {
      if (e is ServerFailure) {
        rethrow;
      }
      final result = ErrorHandlingUtils.handleDioError<Response>(e);
      throw result.fold(
        (failure) => ServerFailure(failure.errMessage, failure.statusCode),
        (_) => ServerFailure('Unexpected error'),
      );
    }
  }
}
