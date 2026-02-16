// features/auth/presentation/bloc/Authcubit.dart
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/core/utils/safe_emit.dart';
import 'package:tionova/features/auth/data/services/token_storage.dart';
import 'package:tionova/features/auth/domain/usecases/forgetPasswordusecase.dart';
import 'package:tionova/features/auth/domain/usecases/googleauthusecase.dart';
import 'package:tionova/features/auth/domain/usecases/loginusecase.dart';
import 'package:tionova/features/auth/domain/usecases/registerusecase.dart';
import 'package:tionova/features/auth/domain/usecases/resetpasswordusecase.dart';
import 'package:tionova/features/auth/domain/usecases/verifyCodeusecase.dart';
import 'package:tionova/features/auth/domain/usecases/verifyEmailusecase.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';

class AuthCubit extends Cubit<AuthState> {
  // --- Forget Password Flow ---
  Future<void> forgetPassword(String email) async {
    safeEmit(AuthLoading());
    final result = await forgetPasswordUseCase.call(email: email);
    await result.fold(
      (failure) {
        safeEmit(ForgetPasswordFailure(failure: failure));
      },
      (void_) {
        safeEmit(ForgetPasswordEmailSent(email: email));
      },
    );
  }

  Future<void> verifyCode({required String email, required String code}) async {
    safeEmit(AuthLoading());
    final result = await verifyCodeUseCase.call(email: email, code: code);
    await result.fold(
      (failure) {
        safeEmit(VerifyCodeFailure(failure: failure));
      },
      (void_) {
        safeEmit(VerifyCodeSuccess(email: email, code: code));
      },
    );
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    safeEmit(AuthLoading());
    final result = await resetPasswordUseCase.execute(
      email: email,
      code: code,
      newPassword: newPassword,
    );
    await result.fold(
      (failure) {
        safeEmit(ResetPasswordFailure(failure: failure));
      },
      (user) async {
        debugPrint(
          '✅ [AuthCubit.resetPassword] Password reset successful: ${user.email}',
        );
        debugPrint('✅ [AuthCubit.resetPassword] User ID: "${user.id}"');
        // Save user ID to local storage for persistence across refreshes
        await tokenStorage.saveUserId(user.id);
        safeEmit(AuthSuccess(user: user));
      },
    );
  }

  AuthCubit({
    required this.googleauthusecase,
    required this.registerUseCase,
    required this.loginUseCase,
    required this.verifyEmailUseCase,
    required this.resetPasswordUseCase,
    required this.forgetPasswordUseCase,
    required this.verifyCodeUseCase,
    required this.tokenStorage,
  }) : super(AuthInitial());
  final LoginUseCase loginUseCase;
  final Googleauthusecase googleauthusecase;
  final RegisterUseCase registerUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final ForgetPasswordUseCase forgetPasswordUseCase;
  final VerifyCodeUseCase verifyCodeUseCase;
  final TokenStorage tokenStorage;

  Future<void> googleSignIn() async {
    safeEmit(AuthLoading());
    final result = await googleauthusecase.call();

    await result.fold(
      (failure) {
        safeEmit(AuthFailure(failure: failure));
      },
      (user) async {
        debugPrint('✅ [AuthCubit.googleSignIn] User signed in: ${user.email}');
        debugPrint('✅ [AuthCubit.googleSignIn] User ID: "${user.id}"');
        // Save user ID to local storage for persistence across refreshes
        await tokenStorage.saveUserId(user.id);
        safeEmit(AuthSuccess(user: user));
      },
    );
  }

  Future<void> start() async {
    try {
      debugPrint('🔵 [AuthCubit] Starting authentication check...');

      // Check if token exists in local storage
      final token = await tokenStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        debugPrint(
          'ℹ️ [AuthCubit] No access token found - user needs to login',
        );
        safeEmit(AuthInitial());
        return;
      }

      debugPrint('✅ [AuthCubit] Access token found, validating with server...');
      safeEmit(AuthLoading());

      // Try to get current user info to validate the token
      final result = await loginUseCase.repository.getCurrentUser();

      await result.fold(
        (failure) async {
          // If token is invalid or expired, clear it and go to initial
          debugPrint(
            '❌ [AuthCubit] Token validation failed: ${failure.errMessage}',
          );
          await tokenStorage.clearTokens();
          safeEmit(AuthInitial());
        },
        (user) async {
          debugPrint(
            '✅ [AuthCubit] User authenticated successfully: ${user.email}',
          );
          debugPrint('✅ [AuthCubit] User ID: "${user.id}"');
          debugPrint('✅ [AuthCubit] Username: ${user.username}');
          // Save user ID to local storage for persistence across refreshes
          await tokenStorage.saveUserId(user.id);
          safeEmit(AuthSuccess(user: user));
        },
      );
    } catch (e) {
      debugPrint('❌ [AuthCubit] Error during auth check: $e');
      // On any error, clear tokens and go to initial state
      try {
        await tokenStorage.clearTokens();
      } catch (clearError) {
        debugPrint('⚠️ [AuthCubit] Error clearing tokens: $clearError');
      }
      safeEmit(AuthInitial());
    }
  }

  // Method to sign out
  Future<void> signOut({bool isTokenExpired = false}) async {
    safeEmit(AuthLoading());

    try {
      await tokenStorage.clearTokens();
      await tokenStorage.clearUserId();

      // If token expired, emit AuthFailure to indicate re-authentication is required
      if (isTokenExpired) {
        safeEmit(
          AuthFailure(
            failure: ServerFailure(
              "Your session has expired. Please login again.",
              "401",
            ),
          ),
        );
      } else {
        safeEmit(AuthInitial());
      }
    } catch (e) {
      if (isTokenExpired) {
        safeEmit(
          AuthFailure(
            failure: ServerFailure(
              "Your session has expired. Please login again.",
              "401",
            ),
          ),
        );
      } else {
        safeEmit(AuthInitial()); // Still emit AuthInitial for normal sign out
      }
    }
  }

  // Method to check if user is authenticated
  bool get isAuthenticated {
    return state is AuthSuccess;
  }

  // Method to register a new user
  Future<void> register(String email, String username, String password) async {
    safeEmit(AuthLoading());
    final result = await registerUseCase.call(email, username, password);
    await result.fold(
      (failure) {
        safeEmit(AuthFailure(failure: failure));
      },
      (void_) {
        safeEmit(RegisterSuccess(email: email));
      },
    );
  }

  // Method to verify email
  Future<void> verifyEmail(String email, String code) async {
    safeEmit(AuthLoading());
    final result = await verifyEmailUseCase.call(email, code);

    await result.fold(
      (failure) {
        safeEmit(AuthFailure(failure: failure));
      },
      (user) async {
        debugPrint(
          '✅ [AuthCubit.verifyEmail] User email verified: ${user.email}',
        );
        debugPrint('✅ [AuthCubit.verifyEmail] User ID: "${user.id}"');
        // Save user ID to local storage for persistence across refreshes
        await tokenStorage.saveUserId(user.id);
        safeEmit(AuthSuccess(user: user));
      },
    );
  }

  // Method to login a user
  Future<void> login(String email, String password) async {
    safeEmit(AuthLoading());
    final result = await loginUseCase.call(email, password);
    await result.fold(
      (failure) {
        safeEmit(AuthFailure(failure: failure));
      },
      (user) async {
        debugPrint('✅ [AuthCubit.login] User logged in: ${user.email}');
        debugPrint('✅ [AuthCubit.login] User ID: "${user.id}"');
        // Save user ID to local storage for persistence across refreshes
        await tokenStorage.saveUserId(user.id);
        safeEmit(AuthSuccess(user: user));
      },
    );
  }

  // ...existing code...
}
