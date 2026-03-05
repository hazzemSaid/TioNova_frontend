// Test for VerifyCodeUseCase
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/domain/usecases/verifyCodeusecase.dart';

import '../../../../helpers/mock_dependencies.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late VerifyCodeUseCase useCase;
  late MockAuthRepo mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    useCase = VerifyCodeUseCase(mockAuthRepo);
  });

  group('VerifyCodeUseCase', () {
    test('should return void when code verification is successful', () async {
      // Arrange
      when(() => mockAuthRepo.verifyCode(
            email: testEmail,
            code: testVerificationCode,
          )).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call(
        email: testEmail,
        code: testVerificationCode,
      );

      // Assert
      expect(result.isRight, true);
      verify(() => mockAuthRepo.verifyCode(
            email: testEmail,
            code: testVerificationCode,
          )).called(1);
    });

    test('should return Failure when code verification fails', () async {
      // Arrange
      final failure = ServerFailure('Invalid or expired code');
      when(() => mockAuthRepo.verifyCode(
            email: testEmail,
            code: testVerificationCode,
          )).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call(
        email: testEmail,
        code: testVerificationCode,
      );

      // Assert
      expect(result.isLeft, true);
      expect(result.left, failure);
      verify(() => mockAuthRepo.verifyCode(
            email: testEmail,
            code: testVerificationCode,
          )).called(1);
    });

    test('should return Failure when repository throws exception', () async {
      // Arrange
      when(() => mockAuthRepo.verifyCode(
            email: testEmail,
            code: testVerificationCode,
          )).thenThrow(Exception(testErrorMessage));

      // Act & Assert
      expect(
        () => useCase.call(email: testEmail, code: testVerificationCode),
        throwsException,
      );
      verify(() => mockAuthRepo.verifyCode(
            email: testEmail,
            code: testVerificationCode,
          )).called(1);
    });

    test('should pass correct email and code to repository', () async {
      // Arrange
      const customEmail = 'custom@example.com';
      const customCode = '654321';
      when(() => mockAuthRepo.verifyCode(
            email: customEmail,
            code: customCode,
          )).thenAnswer((_) async => const Right(null));

      // Act
      await useCase.call(email: customEmail, code: customCode);

      // Assert
      verify(() => mockAuthRepo.verifyCode(
            email: customEmail,
            code: customCode,
          )).called(1);
    });
  });
}
