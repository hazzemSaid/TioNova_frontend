import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data is String
            ? jsonDecode(response.data)
            : response.data as Map<String, dynamic>;
        final token = responseData['token']?.toString();
        final refreshToken = responseData['refreshToken']?.toString();
        if (token == null || refreshToken == null) {
          return Left(
            ServerFailure('Invalid response from server: missing tokens'),
          );
        }
        TokenStorage.saveTokens(token, refreshToken);
        if (responseData['user'] is Map<String, dynamic>) {
          return Right(UserModel.fromJson(responseData['user']));
        } else {
          return Left(ServerFailure('Invalid user data format'));
        }
      } else {
        final errorData = response.data is String
            ? jsonDecode(response.data)
            : response.data as Map<String, dynamic>;
        return Left(
          ServerFailure(
            (errorData['message'] ?? 'Unknown error occurred').toString(),
          ),
        );
      }
    } on DioError catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      await dio.post(
        '/auth/register',
        data: {'email': email, 'username': username, 'password': password},
      );
      return const Right(null);
    } on DioError catch (e) {
      return Left(ServerFailure(e.toString()));
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data is String
            ? jsonDecode(response.data)
            : response.data as Map<String, dynamic>;
        final token = responseData['token']?.toString();
        final refreshToken = responseData['refreshToken']?.toString();
        if (token == null || refreshToken == null) {
          return Left(
            ServerFailure('Invalid response from server: missing tokens'),
          );
        }
        TokenStorage.saveTokens(token, refreshToken);
        if (responseData['user'] is Map<String, dynamic>) {
          return Right(UserModel.fromJson(responseData['user']));
        } else {
          return Left(ServerFailure('Invalid user data format'));
        }
      } else {
        final errorData = response.data is String
            ? jsonDecode(response.data)
            : response.data as Map<String, dynamic>;
        return Left(
          ServerFailure(
            (errorData['message'] ?? 'Unknown error occurred').toString(),
          ),
        );
      }
    } on DioError catch (e) {
      return Left(ServerFailure(e.toString()));
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
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data is String
            ? jsonDecode(response.data)
            : response.data as Map<String, dynamic>;
        final token = responseData['token']?.toString();
        final refreshToken = responseData['refreshToken']?.toString();
        if (token == null || refreshToken == null) {
          return Left(
            ServerFailure('Invalid response from server: missing tokens'),
          );
        }
        TokenStorage.saveTokens(token, refreshToken);
        if (responseData['user'] is Map<String, dynamic>) {
          return Right(UserModel.fromJson(responseData['user']));
        } else {
          return Left(ServerFailure('Invalid user data format'));
        }
      } else {
        final errorData = response.data is String
            ? jsonDecode(response.data)
            : response.data as Map<String, dynamic>;
        return Left(
          ServerFailure(
            (errorData['message'] ?? 'Unknown error occurred').toString(),
          ),
        );
      }
    } on DioError catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgetPassword({required String email}) async {
    final response = await dio.post(
      '/auth/forgot-password',
      data: {'email': email},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return const Right(null);
    }
    return Left(ServerFailure('Failed to send password reset email'));
  }

  @override
  Future<Either<Failure, void>> verifyCode({
    required String email,
    required String code,
  }) async {
    final response = await dio.post(
      '/auth/verify-code',
      data: {'email': email, 'code': code},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return const Right(null);
    }
    return Left(ServerFailure('Failed to verify code'));
  }
}
