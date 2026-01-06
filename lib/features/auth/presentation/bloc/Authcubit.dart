// features/auth/presentation/bloc/Authcubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/core/utils/safe_emit.dart';
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
        safeEmit(AuthSuccess(user: user));
      },
    );
  }

  AuthCubit({
    required this.googleauthusecase,
    // required this.localAuthDataSource,
    required this.registerUseCase,
    required this.loginUseCase,
    required this.verifyEmailUseCase,
    required this.resetPasswordUseCase,
    required this.forgetPasswordUseCase,
    required this.verifyCodeUseCase,
    // Keep the tokenStorage parameter for backward compatibility
    // required TokenStorage tokenStorage,
  }) : super(AuthInitial());
  final LoginUseCase loginUseCase;
  final Googleauthusecase googleauthusecase;
  // final ILocalAuthDataSource localAuthDataSource;
  final RegisterUseCase registerUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final ForgetPasswordUseCase forgetPasswordUseCase;
  final VerifyCodeUseCase verifyCodeUseCase;

  Future<void> googleSignIn() async {
    safeEmit(AuthLoading());
    final result = await googleauthusecase.call();

    await result.fold(
      (failure) {
        safeEmit(AuthFailure(failure: failure));
      },
      (user) async {
        safeEmit(AuthSuccess(user: user));
      },
    );
  }

  Future<void> start() async {
    // safeEmit(AuthLoading()); // Add loading state while checking auth
    safeEmit(AuthInitial());

    // final result = await localAuthDataSource.getCurrentUser();

    // await result.fold(
    //   (failure) async {
    //     // If no user found locally, emit AuthInitial instead of AuthFailure
    //     safeEmit(AuthInitial());
    //   },
    //   (user) async {
    //     safeEmit(AuthSuccess(user: user));
    //   },
    // );
  }

  // Method to sign out
  Future<void> signOut({bool isTokenExpired = false}) async {
    safeEmit(AuthLoading());

    try {
      // await TokenStorage.clearTokens();
      // await localAuthDataSource.signOut();

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
        safeEmit(AuthSuccess(user: user));
      },
    );
  }

  // ...existing code...
}
