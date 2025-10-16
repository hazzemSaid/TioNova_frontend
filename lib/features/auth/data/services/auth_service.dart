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
    String clientId;

    if (kIsWeb) {
      clientId =
          '827260912271-mo4v9vdg3ovr2cra9nn4baagvqfrru6k.apps.googleusercontent.com';
      // For web, don't use serverClientId
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        clientId: clientId,
      );
    } else {
      if (Platform.isIOS) {
        clientId =
            '827260912271-kldgi7qlqjigrrr1pb008quk6lre450e.apps.googleusercontent.com';
      } else {
        clientId =
            '827260912271-mo4v9vdg3ovr2cra9nn4baagvqfrru6k.apps.googleusercontent.com';
      }
      // For mobile platforms, use serverClientId
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
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Left(ServerFailure(errMessage: 'Google sign in was cancelled'));
      }

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth?.idToken;
      if (idToken == null) {
        return Left(
          ServerFailure(
            errMessage:
                'Failed to get ID token from Google. Please check your internet connection.',
          ),
        );
      }

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
