// features/auth/data/services/auth_service.dart
import 'dart:convert';

import 'package:dio/dio.dart';
import 'dart:io' show Platform;
import 'package:either_dart/either.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tionova/core/errors/failure.dart' hide ServerFailure;
import 'package:tionova/core/errors/server_failure.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/auth/data/services/Tokenstorage.dart';

class AuthService {
  final Dio dio;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Web client ID for server-side verification (same for Android/iOS)
    serverClientId:
        '827260912271-mo4v9vdg3ovr2cra9nn4baagvqfrru6k.apps.googleusercontent.com',
    // iOS-specific client ID required on iOS (from GoogleService-Info.plist CLIENT_ID)
    clientId: Platform.isIOS
        ? '827260912271-kldgi7qlqjigrrr1pb008quk6lre450e.apps.googleusercontent.com'
        : '827260912271-mo4v9vdg3ovr2cra9nn4baagvqfrru6k.apps.googleusercontent.com',
  );
  AuthService({required this.dio});
  // Sign in with Google
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      // Sign out first to ensure a fresh sign-in
      await _googleSignIn.signOut();

      // Sign in with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Left(ServerFailure(errMessage: 'Google sign in was cancelled'));
      }

      // Get authentication tokens
      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth?.idToken;
      if (idToken == null) {
        print('Google Authentication Details: ${googleAuth.toString()}');
        print('Access Token: ${googleAuth?.accessToken}');
        return Left(
          ServerFailure(
            errMessage:
                'Failed to get ID token from Google. Please ensure you have an active internet connection and try again.',
          ),
        );
      }

      // Send the Google ID token to your backend
      final response = await dio.post(
        '/auth/google',
        data: {'token': idToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data is String
            ? jsonDecode(response.data)
            : response.data as Map<String, dynamic>;

        print('Auth Response: $responseData');

        final token = responseData['token']?.toString();
        final refreshToken = responseData['refreshToken']?.toString();

        if (token == null || refreshToken == null) {
          return Left(
            ServerFailure(
              errMessage: 'Invalid response from server: missing tokens',
            ),
          );
        }

        TokenStorage.saveTokens(token, refreshToken);

        if (responseData['user'] is Map<String, dynamic>) {
          return Right(UserModel.fromJson(responseData['user']));
        } else {
          return Left(ServerFailure(errMessage: 'Invalid user data format'));
        }
      } else {
        final errorData = response.data is String
            ? jsonDecode(response.data)
            : response.data as Map<String, dynamic>;

        return Left(
          ServerFailure(
            errMessage: (errorData['message'] ?? 'Unknown error occurred')
                .toString(),
          ),
        );
      }
    } catch (e) {
      return Left(ServerFailure(errMessage: e.toString()));
    }
  }
}
