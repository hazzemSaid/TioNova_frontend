import 'dart:convert';
import 'dart:io' show Platform; // تفضل موجودة لكن هنتأكد ما تُستخدمش على الويب

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tionova/core/errors/failure.dart' hide ServerFailure;
import 'package:tionova/core/errors/server_failure.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';

class AuthService {
  final Dio dio;

  late final GoogleSignIn _googleSignIn;

  AuthService({required this.dio}) {
    // ✅ Configure Google Sign-In for each platform with correct client IDs
    if (kIsWeb) {
      // Web: CANNOT use serverClientId - it's not supported on web!
      // The web client ID must match the one configured in index.html
      _googleSignIn = GoogleSignIn(
        clientId:
            '827260912271-mo4v9vdg3ovr2cra9nn4baagvqfrru6k.apps.googleusercontent.com',
        // DO NOT set serverClientId on web - it will cause an assertion error
        scopes: [
          'email',
          'profile',
          'openid', // Required for ID token
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      );
    } else {
      // Mobile platforms - use platform-specific client IDs
      String clientId;
      if (Platform.isIOS) {
        // iOS client ID - matches backend GOOGLE_IOS_CLIENT_ID
        clientId =
            '827260912271-kldgi7qlqjigrrr1pb008quk6lre450e.apps.googleusercontent.com';
      } else {
        // Android client ID - matches backend GOOGLE_ANDROID_CLIENT_ID
        clientId =
            '827260912271-6l6c4hvocqtvt2pqhhpjmeed2a4573ee.apps.googleusercontent.com';
      }
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
          'openid', // Required for ID token
        ],
        // serverClientId is the web/backend client ID for token validation
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

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('🔵 [Auth Object] Has idToken: ${googleAuth.idToken != null}');
      print(
        '🔵 [Auth Object] Has accessToken: ${googleAuth.accessToken != null}',
      );
      print(
        '🔵 [Auth Object] Has serverAuthCode: ${googleAuth.serverAuthCode != null}',
      );

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;
      final String? serverAuthCode = googleAuth.serverAuthCode;

      print(
        '🔵 [ID Token] ${idToken != null ? "Retrieved (${idToken.substring(0, 20)}...)" : "Not available"}',
      );
      print(
        '🔵 [Access Token] ${accessToken != null ? "Retrieved (${accessToken.substring(0, 20)}...)" : "Not available"}',
      );
      print(
        '🔵 [Server Auth Code] ${serverAuthCode != null ? "Retrieved" : "Not available"}',
      );

      // On web, ID token might not be available due to package limitations
      // Try ID token first, fallback to access token
      if (idToken == null && accessToken == null) {
        print('❌ [Critical] No authentication token available');
        return Left(
          ServerFailure(
            errMessage:
                'Failed to get authentication token from Google. Please try again.',
          ),
        );
      }

      // Prepare auth data
      final String tokenToSend = idToken ?? accessToken!;
      final bool usingAccessToken = idToken == null;

      if (usingAccessToken) {
        print('⚠️ [Web Workaround] Using access token (ID token unavailable)');
        print('⚠️ [Note] Backend may reject this - see WEB_ID_TOKEN_FIX.md');
      } else {
        print('🔵 [Backend] Sending ID token to /auth/google...');
      }

      final response = await dio.post(
        '/auth/google',
        data: {'token': tokenToSend, 'idToken': tokenToSend},
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
        // IMPORTANT: Await token saving to ensure it completes (fixes Safari issue)
        // await TokenStorage.saveTokens(token, refreshToken);
        print('✅ [Tokens] Saved successfully');

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

      // Handle specific error types with user-friendly messages
      String errorMessage;

      if (e.toString().contains('popup_closed')) {
        print('ℹ️ [Info] User closed the sign-in popup');
        errorMessage = 'Sign-in cancelled. Please try again.';
      } else if (e.toString().contains('popup_blocked')) {
        errorMessage = 'Popup was blocked. Please allow popups for this site.';
      } else if (e.toString().contains('idpiframe_initialization_failed')) {
        errorMessage =
            'Failed to initialize Google Sign-In. Please refresh the page.';
      } else if (e is DioException) {
        print('❌ [Dio Error] Message: ${e.message}');
        print('❌ [Dio Error] Type: ${e.type}');
        if (e.response != null) {
          print('❌ [Dio Error] Response: ${e.response?.data}');

          // Try to extract error message from response
          try {
            final responseData = e.response?.data is String
                ? jsonDecode(e.response!.data)
                : e.response?.data as Map<String, dynamic>;
            errorMessage =
                responseData['message'] ?? e.message ?? 'Authentication failed';
          } catch (_) {
            errorMessage = e.message ?? 'Authentication failed';
          }
        } else {
          errorMessage =
              e.message ?? 'Network error. Please check your connection.';
        }
      } else {
        errorMessage = 'An unexpected error occurred. Please try again.';
      }

      return Left(ServerFailure(errMessage: errorMessage));
    }
  }
}
