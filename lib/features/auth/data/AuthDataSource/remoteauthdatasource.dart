import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/core/utils/error_handling_utils.dart';
import 'package:tionova/features/auth/data/AuthDataSource/Iauthdatasource.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/auth/data/services/Tokenstorage.dart';
import 'package:tionova/features/auth/data/services/auth_service.dart';

class Remoteauthdatasource implements IAuthDataSource {
  final Dio dio;
  final AuthService authService;
  Remoteauthdatasource({required this.dio, required this.authService});

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      
      return ErrorHandlingUtils.handleApiResponse<UserModel>(
        response: response,
        onSuccess: (data) {
          final responseData = data is String
              ? jsonDecode(data)
              : data as Map<String, dynamic>;
          final token = responseData['token']?.toString();
          final refreshToken = responseData['refreshToken']?.toString();
          if (token == null || refreshToken == null) {
            throw Exception('Invalid response from server: missing tokens');
          }
          TokenStorage.saveTokens(token, refreshToken);
          if (responseData['user'] is Map<String, dynamic>) {
            return UserModel.fromJson(responseData['user']);
          } else {
            throw Exception('Invalid user data format');
          }
        },
      );
    } catch (e) {
      // Handle DioError (old Dio version) or DioException (new Dio version)
      if (e is DioException || e is DioError) {
        return ErrorHandlingUtils.handleDioError(e);
      }
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, void>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {'email': email, 'username': username, 'password': password},
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
  Future<Either<Failure, UserModel>> signInWithGoogle() {
    return authService.signInWithGoogle();
  }

  @override
  Future<Either<Failure, void>> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserModel>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await dio.post(
        '/auth/verify-email',
        data: {'email': email, 'code': code},
      );
      
      return ErrorHandlingUtils.handleApiResponse<UserModel>(
        response: response,
        onSuccess: (data) {
          final responseData = data is String
              ? jsonDecode(data)
              : data as Map<String, dynamic>;
          final token = responseData['token']?.toString();
          final refreshToken = responseData['refreshToken']?.toString();
          if (token == null || refreshToken == null) {
            throw Exception('Invalid response from server: missing tokens');
          }
          TokenStorage.saveTokens(token, refreshToken);
          if (responseData['user'] is Map<String, dynamic>) {
            return UserModel.fromJson(responseData['user']);
          } else {
            throw Exception('Invalid user data format');
          }
        },
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, UserModel>> resetPassword({
    required String email,
    required String newPassword,
    required String code,
  }) async {
    try {
      final response = await dio.post(
        '/auth/reset-password',
        data: {'email': email, 'password': newPassword, 'code': code},
      );
      
      return ErrorHandlingUtils.handleApiResponse<UserModel>(
        response: response,
        onSuccess: (data) {
          final responseData = data is String
              ? jsonDecode(data)
              : data as Map<String, dynamic>;
          final token = responseData['token']?.toString();
          final refreshToken = responseData['refreshToken']?.toString();
          if (token == null || refreshToken == null) {
            throw Exception('Invalid response from server: missing tokens');
          }
          TokenStorage.saveTokens(token, refreshToken);
          if (responseData['user'] is Map<String, dynamic>) {
            return UserModel.fromJson(responseData['user']);
          } else {
            throw Exception('Invalid user data format');
          }
        },
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, void>> forgetPassword({required String email}) async {
    try {
      final response = await dio.post(
        '/auth/forgot-password',
        data: {'email': email},
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
  Future<Either<Failure, void>> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await dio.post(
        '/auth/verify-code',
        data: {'email': email, 'code': code},
      );
      return ErrorHandlingUtils.handleApiResponse<void>(
        response: response,
        onSuccess: (_) => null,
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }
}
