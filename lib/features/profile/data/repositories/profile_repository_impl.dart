import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:tionova/features/auth/data/services/Tokenstorage.dart';
import 'package:tionova/features/profile/data/models/profile_model.dart';
import 'package:tionova/features/profile/data/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final Dio dio;

  ProfileRepositoryImpl({required this.dio});

  @override
  Future<Profile> fetchProfile() async {
    try {
      // Get the access token from secure storage
      final token = await TokenStorage.getAccessToken();

      if (token == null) {
        throw ProfileException('No access token found. Please login again.');
      }

      // Make GET request with Authorization header
      final response = await dio.get(
        '/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final responseData = response.data is String
            ? jsonDecode(response.data)
            : response.data as Map<String, dynamic>;

        if (responseData['success'] == true && responseData['data'] != null) {
          return Profile.fromJson(responseData['data'] as Map<String, dynamic>);
        } else {
          throw ProfileException('Invalid response format from server');
        }
      } else {
        final errorData = response.data is String
            ? jsonDecode(response.data)
            : response.data as Map<String, dynamic>;
        throw ProfileException(
          errorData['message']?.toString() ?? 'Failed to fetch profile',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ProfileException('Authentication failed. Please login again.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ProfileException('Connection timeout. Please try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw ProfileException(
          'No internet connection. Please check your network.',
        );
      } else {
        throw ProfileException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ProfileException('Unexpected error: $e');
    }
  }
}

class ProfileException implements Exception {
  final String message;
  ProfileException(this.message);

  @override
  String toString() => message;
}
