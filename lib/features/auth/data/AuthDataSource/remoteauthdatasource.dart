import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/core/utils/error_handling_utils.dart';
import 'package:tionova/features/auth/data/AuthDataSource/Iauthdatasource.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/auth/data/services/auth_service.dart';
import 'package:tionova/features/auth/data/services/token_storage.dart';

class Remoteauthdatasource implements IAuthDataSource {
  final Dio dio;
  final AuthService authService;
  final TokenStorage tokenStorage;
  Remoteauthdatasource({
    required this.dio,
    required this.authService,
    required this.tokenStorage,
  });

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final accessToken = await tokenStorage.getAccessToken();
      if (accessToken == null) {
        return Left(ServerFailure('No access token found'));
      }

      // Check if token is expired (optional but good for UX)
      final isExpired = await tokenStorage.isAccessTokenExpired();
      if (isExpired) {
        // Try to refresh if possible, but for start() we might just want to know if we need to login
        // Let's try to fetch profile, the interceptor will handle refresh if needed
      }

      final response = await dio.get('/profile');

      debugPrint(
        '🔍 [getCurrentUser] Full response status: ${response.statusCode}',
      );
      debugPrint(
        '🔍 [getCurrentUser] Full response data type: ${response.data.runtimeType}',
      );
      debugPrint('🔍 [getCurrentUser] Full response data: ${response.data}');

      return ErrorHandlingUtils.handleApiResponse<UserModel>(
        response: response,
        onSuccess: (data) {
          debugPrint(
            '🔍 [getCurrentUser] API response data keys: ${data.keys.toList()}',
          );
          if (data['user'] is Map<String, dynamic>) {
            debugPrint('🔍 [getCurrentUser] Parsing nested user object');
            debugPrint(
              '🔍 [getCurrentUser] User data keys: ${(data['user'] as Map<String, dynamic>).keys.toList()}',
            );
            return UserModel.fromJson(data['user'] as Map<String, dynamic>);
          } else {
            // Some backends return the user object directly at the root
            debugPrint('🔍 [getCurrentUser] Parsing user object from root');
            return UserModel.fromJson(data as Map<String, dynamic>);
          }
        },
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError<UserModel>(e);
    }
  }

  @override
  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return Left(ServerFailure('Email and password cannot be empty'));
    }

    try {
      final response = await dio.post(
        '/auth/login',
        data: {'email': email.trim(), 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is String
            ? response.data
            : response.data as Map<String, dynamic>;

        final token = data['token']?.toString();
        final refreshToken = data['refreshToken']?.toString();

        if (token == null || refreshToken == null) {
          return Left(
            ServerFailure('Invalid response from server: missing tokens'),
          );
        }

        // Get token expiry from response (default to 1 hour if not provided)
        final expiresIn = data['expiresIn'] is int
            ? data['expiresIn'] as int
            : (int.tryParse(data['expiresIn']?.toString() ?? '3600') ?? 3600);

        // CRITICAL: Await token saving to ensure persistence completes
        await tokenStorage.saveTokens(
          token,
          refreshToken,
          expiresIn: expiresIn,
        );
        debugPrint('✅ [Login] Tokens saved successfully');

        debugPrint('🔍 [Login] API response data keys: ${data.keys.toList()}');
        if (data['user'] is Map<String, dynamic>) {
          debugPrint(
            '🔍 [Login] User data keys: ${(data['user'] as Map<String, dynamic>).keys.toList()}',
          );
          return Right(
            UserModel.fromJson(data['user'] as Map<String, dynamic>),
          );
        } else {
          return Left(ServerFailure('Invalid user data format'));
        }
      } else {
        final errorMessage =
            response.data['message']?.toString() ?? 'Login failed';
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      return ErrorHandlingUtils.handleDioError<UserModel>(e);
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
  Future<Either<Failure, void>> signOut() async {
    try {
      await tokenStorage.clearTokens();
      debugPrint('✅ Tokens cleared successfully');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to sign out: $e'));
    }
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
        final data = response.data is String
            ? response.data
            : response.data as Map<String, dynamic>;

        final token = data['token']?.toString();
        final refreshToken = data['refreshToken']?.toString();

        if (token == null || refreshToken == null) {
          return Left(
            ServerFailure('Invalid response from server: missing tokens'),
          );
        }

        final expiresIn = data['expiresIn'] is int
            ? data['expiresIn'] as int
            : (int.tryParse(data['expiresIn']?.toString() ?? '3600') ?? 3600);

        // CRITICAL: Await token saving to ensure persistence completes
        await tokenStorage.saveTokens(
          token,
          refreshToken,
          expiresIn: expiresIn,
        );
        debugPrint('✅ [VerifyEmail] Tokens saved successfully');

        debugPrint(
          '🔍 [VerifyEmail] API response data keys: ${data.keys.toList()}',
        );
        if (data['user'] is Map<String, dynamic>) {
          debugPrint(
            '🔍 [VerifyEmail] User data keys: ${(data['user'] as Map<String, dynamic>).keys.toList()}',
          );
          return Right(
            UserModel.fromJson(data['user'] as Map<String, dynamic>),
          );
        } else {
          return Left(ServerFailure('Invalid user data format'));
        }
      } else {
        final errorMessage =
            response.data['message']?.toString() ?? 'Email verification failed';
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      return ErrorHandlingUtils.handleDioError<UserModel>(e);
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
        final data = response.data is String
            ? response.data
            : response.data as Map<String, dynamic>;

        final token = data['token']?.toString();
        final refreshToken = data['refreshToken']?.toString();

        if (token == null || refreshToken == null) {
          return Left(
            ServerFailure('Invalid response from server: missing tokens'),
          );
        }

        final expiresIn = data['expiresIn'] is int
            ? data['expiresIn'] as int
            : (int.tryParse(data['expiresIn']?.toString() ?? '3600') ?? 3600);

        // CRITICAL: Await token saving to ensure persistence completes
        await tokenStorage.saveTokens(
          token,
          refreshToken,
          expiresIn: expiresIn,
        );
        debugPrint('✅ [ResetPassword] Tokens saved successfully');

        debugPrint(
          '🔍 [ResetPassword] API response data keys: ${data.keys.toList()}',
        );
        if (data['user'] is Map<String, dynamic>) {
          debugPrint(
            '🔍 [ResetPassword] User data keys: ${(data['user'] as Map<String, dynamic>).keys.toList()}',
          );
          return Right(
            UserModel.fromJson(data['user'] as Map<String, dynamic>),
          );
        } else {
          return Left(ServerFailure('Invalid user data format'));
        }
      } else {
        final errorMessage =
            response.data['message']?.toString() ?? 'Password reset failed';
        return Left(ServerFailure(errorMessage));
      }
    } catch (e) {
      return ErrorHandlingUtils.handleDioError<UserModel>(e);
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
