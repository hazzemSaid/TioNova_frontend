import 'dart:io';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';

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

      if (response.statusCode == 200) {
        return Right(response);
      } else {
        return Left(ServerFailure('Failed to load user profile'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Response> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      // Check if we have a file to upload
      final File? imageFile = profileData['profilePicture'] as File?;

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

        final response = await dio.put('/profile', data: formData);

        if (response.statusCode != 200) {
          throw ServerFailure('Failed to update profile');
        }

        return response;
      } else {
        // No file, use regular JSON
        final response = await dio.put(
          '/profile',
          data: {
            'username': profileData['username'] ?? '',
            'universityCollege': profileData['universityCollege'] ?? '',
          },
        );

        if (response.statusCode != 200) {
          throw ServerFailure('Failed to update profile');
        }

        return response;
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
