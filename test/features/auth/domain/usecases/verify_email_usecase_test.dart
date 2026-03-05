// Test for VerifyEmailUseCase
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/domain/usecases/verifyEmailusecase.dart';

import '../../../../helpers/mock_dependencies.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late VerifyEmailUseCase useCase;
  late MockAuthRepo mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    useCase = VerifyEmailUseCase(mockAuthRepo);
  });

  group('VerifyEmailUseCase', () {
    test('should return UserModel when email verification is successful',
        () async {
      // Arrange
      when(() => mockAuthRepo.verifyEmail(testEmail, testVerificationCode))
          .thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase.call(testEmail, testVerificationCode);

      // Assert
      expect(result.isRight, true);
      expect(result.right, testUser);
      verify(() => mockAuthRepo.verifyEmail(testEmail, testVerificationCode))
          .called(1);
    });

    test('should return Failure when email verification fails', () async {
      // Arrange
      final failure = ServerFailure('Invalid or expired verification code');
      when(() => mockAuthRepo.verifyEmail(testEmail, testVerificationCode))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call(testEmail, testVerificationCode);

      // Assert
      expect(result.isLeft, true);
      expect(result.left, failure);
      verify(() => mockAuthRepo.verifyEmail(testEmail, testVerificationCode))
          .called(1);
    });

    test('should return Failure when repository throws exception', () async {
      // Arrange
      when(() => mockAuthRepo.verifyEmail(testEmail, testVerificationCode))
          .thenThrow(Exception(testErrorMessage));

      // Act & Assert
      expect(
        () => useCase.call(testEmail, testVerificationCode),
        throwsException,
      );
      verify(() => mockAuthRepo.verifyEmail(testEmail, testVerificationCode))
          .called(1);
    });

    test('should pass correct email and code to repository', () async {
      // Arrange
      const customEmail = 'verify@example.com';
      const customCode = '999888';
      when(() => mockAuthRepo.verifyEmail(customEmail, customCode))
          .thenAnswer((_) async => Right(testUser));

      // Act
      await useCase.call(customEmail, customCode);

      // Assert
      verify(() => mockAuthRepo.verifyEmail(customEmail, customCode)).called(1);
    });
  });
}
