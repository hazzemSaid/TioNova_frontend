// features/auth/presentation/bloc/Authcubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/data/AuthDataSource/ilocal_auth_data_source.dart';
import 'package:tionova/features/auth/data/services/Tokenstorage.dart';
import 'package:tionova/features/auth/domain/usecases/googleauthusecase.dart';
import 'package:tionova/features/auth/domain/usecases/registerusecase.dart';
import 'package:tionova/features/auth/domain/usecases/verifyEmailusecase.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.googleauthusecase,
    required this.localAuthDataSource,
    required this.registerUseCase,
    required this.verifyEmailUseCase,
    // Keep the tokenStorage parameter for backward compatibility
    required TokenStorage tokenStorage,
  }) : super(AuthInitial());

  final Googleauthusecase googleauthusecase;
  final ILocalAuthDataSource localAuthDataSource;
  final RegisterUseCase registerUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;

  Future<void> googleSignIn() async {
    emit(AuthLoading());
    final result = await googleauthusecase.call();

    await result.fold(
      (failure) {
        emit(AuthFailure(failure: failure));
      },
      (user) async {
        final token = await TokenStorage.getAccessToken() ?? "";
        emit(AuthSuccess(user: user, token: token));
      },
    );
  }

  Future<void> start() async {
    emit(AuthLoading()); // Add loading state while checking auth

    final result = await localAuthDataSource.getCurrentUser();

    await result.fold(
      (failure) async {
        // If no user found locally, emit AuthInitial instead of AuthFailure
        emit(AuthInitial());
      },
      (user) async {
        final token = await TokenStorage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          emit(AuthSuccess(user: user, token: token));
        } else {
          // Clear corrupted user data and emit AuthInitial
          await localAuthDataSource.signOut();
          emit(AuthInitial());
        }
      },
    );
  }

  // Method to sign out
  Future<void> signOut({bool isTokenExpired = false}) async {
    emit(AuthLoading());

    try {
      await TokenStorage.clearTokens();
      await localAuthDataSource.signOut();

      // If token expired, emit AuthFailure to indicate re-authentication is required
      if (isTokenExpired) {
        emit(
          AuthFailure(
            failure: ServerFailure(
              "Your session has expired. Please login again.",
              "401",
            ),
          ),
        );
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      if (isTokenExpired) {
        emit(
          AuthFailure(
            failure: ServerFailure(
              "Your session has expired. Please login again.",
              "401",
            ),
          ),
        );
      } else {
        emit(AuthInitial()); // Still emit AuthInitial for normal sign out
      }
    }
  }

  // Method to check if user is authenticated
  bool get isAuthenticated {
    return state is AuthSuccess;
  }

  // Method to register a new user
  Future<void> register(String email, String username, String password) async {
    emit(AuthLoading());
    final result = await registerUseCase.call(email, username, password);
    await result.fold(
      (failure) {
        emit(AuthFailure(failure: failure));
      },
      (void_) {
        emit(RegisterSuccess(email: email));
      },
    );
  }

  // Method to verify email
  Future<void> verifyEmail(String email, String code) async {
    emit(AuthLoading());
    final result = await verifyEmailUseCase.call(email, code);

    await result.fold(
      (failure) {
        emit(AuthFailure(failure: failure));
      },
      (user) async {
        final token = await TokenStorage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          emit(AuthSuccess(user: user, token: token));
        } else {
          emit(
            AuthFailure(
              failure: ServerFailure(
                "Failed to get token after verification",
                "401",
              ),
            ),
          );
        }
      },
    );
  }
}
