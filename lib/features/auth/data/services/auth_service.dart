import 'dart:convert';
import 'dart:io' show Platform; // تفضل موجودة لكن هنتأكد ما تُستخدمش على الويب

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tionova/core/errors/failure.dart' hide ServerFailure;
import 'package:tionova/core/errors/server_failure.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/auth/data/services/Tokenstorage.dart';

class AuthService {
  final Dio dio;

  late final GoogleSignIn _googleSignIn;

  AuthService({required this.dio}) {
    // ✅ نحدد الـ clientId بطريقة آمنة لكل Platform
    if (kIsWeb) {
      // For web, only use clientId (not serverClientId)
      _googleSignIn = GoogleSignIn(
        clientId:
            '827260912271-mo4v9vdg3ovr2cra9nn4baagvqfrru6k.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
    } else {
      // For mobile platforms
      String clientId;
      if (Platform.isIOS) {
        clientId =
            '827260912271-kldgi7qlqjigrrr1pb008quk6lre450e.apps.googleusercontent.com';
      } else {
        // Android
        clientId =
            '827260912271-mo4v9vdg3ovr2cra9nn4baagvqfrru6k.apps.googleusercontent.com';
      }
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '827260912271-mo4v9vdg3ovr2cra9nn4baagvqfrru6k.apps.googleusercontent.com',
        clientId: clientId,
      );
    }
  }

  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      print('🔵 [Google Sign-In] Starting authentication...');
      print('🔵 [Platform] ${kIsWeb ? "Web" : "Mobile"}');

      await _googleSignIn.signOut();
      print('🔵 [Google Sign-In] Previous session cleared');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print(
        '🔵 [Google Sign-In] Sign-in returned: ${googleUser != null ? "User account" : "null (cancelled)"}',
      );

      if (googleUser == null) {
        print('❌ [Google Sign-In] User cancelled sign-in');
        return Left(ServerFailure(errMessage: 'Google sign in was cancelled'));
      }

      print('✅ [Google User] Email: ${googleUser.email}');
      print('✅ [Google User] Display Name: ${googleUser.displayName}');

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth?.idToken;
      print(
        '🔵 [ID Token] ${idToken != null ? "Retrieved (${idToken.substring(0, 20)}...)" : "Failed to retrieve"}',
      );

      if (idToken == null) {
        print('❌ [ID Token] Failed to get ID token from Google');
        return Left(
          ServerFailure(
            errMessage:
                'Failed to get ID token from Google. Please check your internet connection.',
          ),
        );
      }

      print('🔵 [Backend] Sending request to /auth/google...');
      final response = await dio.post(
        '/auth/google',
        data: {'token': idToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.json,
        ),
      );

      print('🔵 [Backend] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data is String
            ? jsonDecode(response.data)
            : response.data as Map<String, dynamic>;

        print('✅ [Backend] Response received successfully');

        final token = responseData['token']?.toString();
        final refreshToken = responseData['refreshToken']?.toString();

        if (token == null || refreshToken == null) {
          print('❌ [Backend] Missing tokens in response');
          return Left(
            ServerFailure(
              errMessage: 'Invalid response from server: missing tokens',
            ),
          );
        }

        print('✅ [Tokens] Saving access and refresh tokens...');
        TokenStorage.saveTokens(token, refreshToken);

        if (responseData['user'] is Map<String, dynamic>) {
          print('✅ [Auth] Sign-in completed successfully! 🎉');
          return Right(UserModel.fromJson(responseData['user']));
        } else {
          print('❌ [Backend] Invalid user data format');
          return Left(ServerFailure(errMessage: 'Invalid user data format'));
        }
      } else {
        final errorData = response.data is String
            ? jsonDecode(response.data)
            : response.data as Map<String, dynamic>;

        final errorMessage = (errorData['message'] ?? 'Unknown error occurred')
            .toString();
        print(
          '❌ [Backend] Error: $errorMessage (Status: ${response.statusCode})',
        );

        return Left(ServerFailure(errMessage: errorMessage));
      }
    } catch (e) {
      print('❌ [Exception] Error during sign-in: $e');
      print('❌ [Exception] Type: ${e.runtimeType}');
      if (e is DioException) {
        print('❌ [Dio Error] Message: ${e.message}');
        print('❌ [Dio Error] Type: ${e.type}');
        if (e.response != null) {
          print('❌ [Dio Error] Response: ${e.response?.data}');
        }
      }
      return Left(ServerFailure(errMessage: e.toString()));
    }
  }
}
