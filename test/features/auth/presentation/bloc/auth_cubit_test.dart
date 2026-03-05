// Test for AuthCubit
import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/data/services/token_storage.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';

import '../../../../helpers/mock_dependencies.dart';
import '../../../../helpers/test_data.dart';

// Mock TokenStorage
class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late AuthCubit authCubit;
  late MockLoginUseCase mockLoginUseCase;
  late MockGoogleAuthUseCase mockGoogleAuthUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockVerifyEmailUseCase mockVerifyEmailUseCase;
  late MockResetPasswordUseCase mockResetPasswordUseCase;
  late MockForgetPasswordUseCase mockForgetPasswordUseCase;
  late MockVerifyCodeUseCase mockVerifyCodeUseCase;
  late MockTokenStorage mockTokenStorage;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockGoogleAuthUseCase = MockGoogleAuthUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockVerifyEmailUseCase = MockVerifyEmailUseCase();
    mockResetPasswordUseCase = MockResetPasswordUseCase();
    mockForgetPasswordUseCase = MockForgetPasswordUseCase();
    mockVerifyCodeUseCase = MockVerifyCodeUseCase();
    mockTokenStorage = MockTokenStorage();

    authCubit = AuthCubit(
      loginUseCase: mockLoginUseCase,
      googleauthusecase: mockGoogleAuthUseCase,
      registerUseCase: mockRegisterUseCase,
      verifyEmailUseCase: mockVerifyEmailUseCase,
      resetPasswordUseCase: mockResetPasswordUseCase,
      forgetPasswordUseCase: mockForgetPasswordUseCase,
      verifyCodeUseCase: mockVerifyCodeUseCase,
      tokenStorage: mockTokenStorage,
    );

    // Setup default behavior for tokenStorage
    when(() => mockTokenStorage.saveUserId(any()))
        .thenAnswer((_) async => Future.value());
    when(() => mockTokenStorage.clearTokens())
        .thenAnswer((_) async => Future.value());
    when(() => mockTokenStorage.clearUserId())
        .thenAnswer((_) async => Future.value());
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      expect(authCubit.state, isA<AuthInitial>());
    });

    group('login', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthSuccess] when login is successful',
        build: () {
          when(() => mockLoginUseCase.call(testEmail, testPassword))
              .thenAnswer((_) async => Right(testUser));
          return authCubit;
        },
        act: (cubit) => cubit.login(testEmail, testPassword),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccess>()
              .having((state) => state.user, 'user', testUser),
        ],
        verify: (_) {
          verify(() => mockLoginUseCase.call(testEmail, testPassword))
              .called(1);
          verify(() => mockTokenStorage.saveUserId(testUser.id)).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthFailure] when login fails',
        build: () {
          final failure = ServerFailure(testAuthErrorMessage);
          when(() => mockLoginUseCase.call(testEmail, testPassword))
              .thenAnswer((_) async => Left(failure));
          return authCubit;
        },
        act: (cubit) => cubit.login(testEmail, testPassword),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>()
              .having((state) => state.failure.errMessage, 'failure', testAuthErrorMessage),
        ],
        verify: (_) {
          verify(() => mockLoginUseCase.call(testEmail, testPassword))
              .called(1);
          verifyNever(() => mockTokenStorage.saveUserId(any()));
        },
      );
    });

    group('register', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, RegisterSuccess] when registration is successful',
        build: () {
          when(() =>
                  mockRegisterUseCase.call(testEmail, testUsername, testPassword))
              .thenAnswer((_) async => const Right(null));
          return authCubit;
        },
        act: (cubit) => cubit.register(testEmail, testUsername, testPassword),
        expect: () => [
          isA<AuthLoading>(),
          isA<RegisterSuccess>()
              .having((state) => state.email, 'email', testEmail),
        ],
        verify: (_) {
          verify(() =>
                  mockRegisterUseCase.call(testEmail, testUsername, testPassword))
              .called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthFailure] when registration fails',
        build: () {
          final failure = ServerFailure('Email already exists');
          when(() =>
                  mockRegisterUseCase.call(testEmail, testUsername, testPassword))
              .thenAnswer((_) async => Left(failure));
          return authCubit;
        },
        act: (cubit) => cubit.register(testEmail, testUsername, testPassword),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>(),
        ],
      );
    });

    group('googleSignIn', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthSuccess] when Google sign-in is successful',
        build: () {
          when(() => mockGoogleAuthUseCase.call())
              .thenAnswer((_) async => Right(testUser));
          return authCubit;
        },
        act: (cubit) => cubit.googleSignIn(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccess>()
              .having((state) => state.user, 'user', testUser),
        ],
        verify: (_) {
          verify(() => mockGoogleAuthUseCase.call()).called(1);
          verify(() => mockTokenStorage.saveUserId(testUser.id)).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthFailure] when Google sign-in fails',
        build: () {
          final failure = ServerFailure('Google sign-in cancelled');
          when(() => mockGoogleAuthUseCase.call())
              .thenAnswer((_) async => Left(failure));
          return authCubit;
        },
        act: (cubit) => cubit.googleSignIn(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>(),
        ],
      );
    });

    group('verifyEmail', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthSuccess] when email verification is successful',
        build: () {
          when(() => mockVerifyEmailUseCase.call(testEmail, testVerificationCode))
              .thenAnswer((_) async => Right(testUser));
          return authCubit;
        },
        act: (cubit) => cubit.verifyEmail(testEmail, testVerificationCode),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccess>()
              .having((state) => state.user, 'user', testUser),
        ],
        verify: (_) {
          verify(() =>
                  mockVerifyEmailUseCase.call(testEmail, testVerificationCode))
              .called(1);
          verify(() => mockTokenStorage.saveUserId(testUser.id)).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthFailure] when email verification fails',
        build: () {
          final failure = ServerFailure('Invalid verification code');
          when(() => mockVerifyEmailUseCase.call(testEmail, testVerificationCode))
              .thenAnswer((_) async => Left(failure));
          return authCubit;
        },
        act: (cubit) => cubit.verifyEmail(testEmail, testVerificationCode),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>(),
        ],
      );
    });

    group('forgetPassword', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, ForgetPasswordEmailSent] when forget password is successful',
        build: () {
          when(() => mockForgetPasswordUseCase.call(email: testEmail))
              .thenAnswer((_) async => const Right(null));
          return authCubit;
        },
        act: (cubit) => cubit.forgetPassword(testEmail),
        expect: () => [
          isA<AuthLoading>(),
          isA<ForgetPasswordEmailSent>()
              .having((state) => state.email, 'email', testEmail),
        ],
        verify: (_) {
          verify(() => mockForgetPasswordUseCase.call(email: testEmail))
              .called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, ForgetPasswordFailure] when forget password fails',
        build: () {
          final failure = ServerFailure('User not found');
          when(() => mockForgetPasswordUseCase.call(email: testEmail))
              .thenAnswer((_) async => Left(failure));
          return authCubit;
        },
        act: (cubit) => cubit.forgetPassword(testEmail),
        expect: () => [
          isA<AuthLoading>(),
          isA<ForgetPasswordFailure>(),
        ],
      );
    });

    group('verifyCode', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, VerifyCodeSuccess] when code verification is successful',
        build: () {
          when(() => mockVerifyCodeUseCase.call(
                email: testEmail,
                code: testVerificationCode,
              )).thenAnswer((_) async => const Right(null));
          return authCubit;
        },
        act: (cubit) =>
            cubit.verifyCode(email: testEmail, code: testVerificationCode),
        expect: () => [
          isA<AuthLoading>(),
          isA<VerifyCodeSuccess>()
              .having((state) => state.email, 'email', testEmail)
              .having((state) => state.code, 'code', testVerificationCode),
        ],
        verify: (_) {
          verify(() => mockVerifyCodeUseCase.call(
                email: testEmail,
                code: testVerificationCode,
              )).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, VerifyCodeFailure] when code verification fails',
        build: () {
          final failure = ServerFailure('Invalid or expired code');
          when(() => mockVerifyCodeUseCase.call(
                email: testEmail,
                code: testVerificationCode,
              )).thenAnswer((_) async => Left(failure));
          return authCubit;
        },
        act: (cubit) =>
            cubit.verifyCode(email: testEmail, code: testVerificationCode),
        expect: () => [
          isA<AuthLoading>(),
          isA<VerifyCodeFailure>(),
        ],
      );
    });

    group('resetPassword', () {
      const newPassword = 'NewTest123!@#';

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthSuccess] when password reset is successful',
        build: () {
          when(() => mockResetPasswordUseCase.execute(
                email: testEmail,
                code: testVerificationCode,
                newPassword: newPassword,
              )).thenAnswer((_) async => Right(testUser));
          return authCubit;
        },
        act: (cubit) => cubit.resetPassword(
          email: testEmail,
          code: testVerificationCode,
          newPassword: newPassword,
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthSuccess>()
              .having((state) => state.user, 'user', testUser),
        ],
        verify: (_) {
          verify(() => mockResetPasswordUseCase.execute(
                email: testEmail,
                code: testVerificationCode,
                newPassword: newPassword,
              )).called(1);
          verify(() => mockTokenStorage.saveUserId(testUser.id)).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, ResetPasswordFailure] when password reset fails',
        build: () {
          final failure = ServerFailure('Invalid reset code');
          when(() => mockResetPasswordUseCase.execute(
                email: testEmail,
                code: testVerificationCode,
                newPassword: newPassword,
              )).thenAnswer((_) async => Left(failure));
          return authCubit;
        },
        act: (cubit) => cubit.resetPassword(
          email: testEmail,
          code: testVerificationCode,
          newPassword: newPassword,
        ),
        expect: () => [
          isA<AuthLoading>(),
          isA<ResetPasswordFailure>(),
        ],
      );
    });

    group('signOut', () {
      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthInitial] when sign out is successful',
        build: () => authCubit,
        act: (cubit) => cubit.signOut(),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthInitial>(),
        ],
        verify: (_) {
          verify(() => mockTokenStorage.clearTokens()).called(1);
          verify(() => mockTokenStorage.clearUserId()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits [AuthLoading, AuthFailure] when token expired',
        build: () => authCubit,
        act: (cubit) => cubit.signOut(isTokenExpired: true),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>(),
        ],
        verify: (_) {
          verify(() => mockTokenStorage.clearTokens()).called(1);
          verify(() => mockTokenStorage.clearUserId()).called(1);
        },
      );
    });

    group('isAuthenticated', () {
      test('returns true when state is AuthSuccess', () {
        authCubit.emit(AuthSuccess(user: testUser));
        expect(authCubit.isAuthenticated, true);
      });

      test('returns false when state is AuthInitial', () {
        authCubit.emit(AuthInitial());
        expect(authCubit.isAuthenticated, false);
      });

      test('returns false when state is AuthLoading', () {
        authCubit.emit(AuthLoading());
        expect(authCubit.isAuthenticated, false);
      });

      test('returns false when state is AuthFailure', () {
        authCubit.emit(AuthFailure(failure: ServerFailure(testErrorMessage)));
        expect(authCubit.isAuthenticated, false);
      });
    });
  });
}
