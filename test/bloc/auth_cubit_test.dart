import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/auth/data/services/Tokenstorage.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';

import '../mocks.dart';

void main() {
  group('AuthCubit', () {
    late MockLoginUseCase mockLogin;
    late MockGoogleAuthUseCase mockGoogle;
    late MockLocalAuthDataSource mockLocal;
    late AuthCubit cubit;

    setUp(() {
      mockLogin = MockLoginUseCase();
      mockGoogle = MockGoogleAuthUseCase();
      mockLocal = MockLocalAuthDataSource();
      cubit = AuthCubit(
        googleauthusecase: mockGoogle,
        localAuthDataSource: mockLocal,
        registerUseCase: MockRegisterUseCase(),
        loginUseCase: mockLogin,
        verifyEmailUseCase: MockVerifyEmailUseCase(),
        resetPasswordUseCase: MockResetPasswordUseCase(),
        forgetPasswordUseCase: MockForgetPasswordUseCase(),
        verifyCodeUseCase: MockVerifyCodeUseCase(),
        tokenStorage: TokenStorage(),
      );
    });

    final testUser = UserModel(
      id: 'u1',
      email: 'a@b.com',
      username: 'a',
      profilePicture: '',
      streak: 0,
      verified: false,
    );

    blocTest<AuthCubit, dynamic>(
      'emits AuthLoading then AuthSuccess on successful login',
      build: () {
        when(
          () => mockLogin.call(any(), any()),
        ).thenAnswer((_) async => Right(testUser));
        return cubit;
      },
      act: (c) => c.login('a@b.com', 'pass'),
      expect: () => [isA<dynamic>(), isA<dynamic>()],
    );

    blocTest<AuthCubit, dynamic>(
      'emits AuthLoading then AuthFailure on failed login',
      build: () {
        when(
          () => mockLogin.call(any(), any()),
        ).thenAnswer((_) async => Left(ServerFailure('fail')));
        return cubit;
      },
      act: (c) => c.login('a@b.com', 'pass'),
      expect: () => [isA<dynamic>(), isA<dynamic>()],
    );

    blocTest<AuthCubit, dynamic>(
      'start emits AuthInitial when local user not found',
      build: () {
        when(
          () => mockLocal.getCurrentUser(),
        ).thenAnswer((_) async => Left(ServerFailure('no user')));
        return cubit;
      },
      act: (c) => c.start(),
      expect: () => [isA<dynamic>(), isA<dynamic>()],
    );

    blocTest<AuthCubit, dynamic>(
      'start emits AuthSuccess when local user found',
      build: () {
        when(
          () => mockLocal.getCurrentUser(),
        ).thenAnswer((_) async => Right(testUser));
        return cubit;
      },
      act: (c) => c.start(),
      expect: () => [isA<dynamic>(), isA<dynamic>()],
    );
  });
}
