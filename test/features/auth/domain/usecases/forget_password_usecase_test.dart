// Test for ForgetPasswordUseCase
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/domain/usecases/forgetPasswordusecase.dart';

import '../../../../helpers/mock_dependencies.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late ForgetPasswordUseCase useCase;
  late MockAuthRepo mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    useCase = ForgetPasswordUseCase(mockAuthRepo);
  });

  group('ForgetPasswordUseCase', () {
    test('should return void when forget password request is successful',
        () async {
      // Arrange
      when(() => mockAuthRepo.forgetPassword(email: testEmail))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call(email: testEmail);

      // Assert
      expect(result.isRight, true);
      verify(() => mockAuthRepo.forgetPassword(email: testEmail)).called(1);
    });

    test('should return Failure when forget password request fails', () async {
      // Arrange
      final failure = ServerFailure('User not found');
      when(() => mockAuthRepo.forgetPassword(email: testEmail))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call(email: testEmail);

      // Assert
      expect(result.isLeft, true);
      expect(result.left, failure);
      verify(() => mockAuthRepo.forgetPassword(email: testEmail)).called(1);
    });

    test('should return Failure when repository throws exception', () async {
      // Arrange
      when(() => mockAuthRepo.forgetPassword(email: testEmail))
          .thenThrow(Exception(testErrorMessage));

      // Act & Assert
      expect(
        () => useCase.call(email: testEmail),
        throwsException,
      );
      verify(() => mockAuthRepo.forgetPassword(email: testEmail)).called(1);
    });

    test('should pass correct email to repository', () async {
      // Arrange
      const customEmail = 'custom@example.com';
      when(() => mockAuthRepo.forgetPassword(email: customEmail))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase.call(email: customEmail);

      // Assert
      verify(() => mockAuthRepo.forgetPassword(email: customEmail)).called(1);
    });
  });
}
