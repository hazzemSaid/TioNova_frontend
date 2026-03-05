// Test for ResetPasswordUseCase
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/domain/usecases/resetpasswordusecase.dart';

import '../../../../helpers/mock_dependencies.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late ResetPasswordUseCase useCase;
  late MockAuthRepo mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    useCase = ResetPasswordUseCase(mockAuthRepo);
  });

  group('ResetPasswordUseCase', () {
    const newPassword = 'NewTest123!@#';

    test('should return UserModel when password reset is successful', () async {
      // Arrange
      when(() => mockAuthRepo.resetPassword(
            email: testEmail,
            code: testVerificationCode,
            newPassword: newPassword,
          )).thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase.execute(
        email: testEmail,
        code: testVerificationCode,
        newPassword: newPassword,
      );

      // Assert
      expect(result.isRight, true);
      expect(result.right, testUser);
      verify(() => mockAuthRepo.resetPassword(
            email: testEmail,
            code: testVerificationCode,
            newPassword: newPassword,
          )).called(1);
    });

    test('should return Failure when password reset fails', () async {
      // Arrange
      final failure = ServerFailure('Invalid or expired reset code');
      when(() => mockAuthRepo.resetPassword(
            email: testEmail,
            code: testVerificationCode,
            newPassword: newPassword,
          )).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.execute(
        email: testEmail,
        code: testVerificationCode,
        newPassword: newPassword,
      );

      // Assert
      expect(result.isLeft, true);
      expect(result.left, failure);
      verify(() => mockAuthRepo.resetPassword(
            email: testEmail,
            code: testVerificationCode,
            newPassword: newPassword,
          )).called(1);
    });

    test('should return Failure when repository throws exception', () async {
      // Arrange
      when(() => mockAuthRepo.resetPassword(
            email: testEmail,
            code: testVerificationCode,
            newPassword: newPassword,
          )).thenThrow(Exception(testErrorMessage));

      // Act & Assert
      expect(
        () => useCase.execute(
          email: testEmail,
          code: testVerificationCode,
          newPassword: newPassword,
        ),
        throwsException,
      );
      verify(() => mockAuthRepo.resetPassword(
            email: testEmail,
            code: testVerificationCode,
            newPassword: newPassword,
          )).called(1);
    });

    test('should pass correct data to repository', () async {
      // Arrange
      const customEmail = 'reset@example.com';
      const customCode = '777888';
      const customPassword = 'CustomNew123!';
      when(() => mockAuthRepo.resetPassword(
            email: customEmail,
            code: customCode,
            newPassword: customPassword,
          )).thenAnswer((_) async => Right(testUser));

      // Act
      await useCase.execute(
        email: customEmail,
        code: customCode,
        newPassword: customPassword,
      );

      // Assert
      verify(() => mockAuthRepo.resetPassword(
            email: customEmail,
            code: customCode,
            newPassword: customPassword,
          )).called(1);
    });
  });
}
