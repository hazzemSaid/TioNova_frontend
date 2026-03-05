// Test for LoginUseCase
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/domain/usecases/loginusecase.dart';

import '../../../../helpers/mock_dependencies.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late LoginUseCase useCase;
  late MockAuthRepo mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    useCase = LoginUseCase(mockAuthRepo);
  });

  group('LoginUseCase', () {
    test('should return UserModel when login is successful', () async {
      // Arrange
      when(() => mockAuthRepo.login(testEmail, testPassword))
          .thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase.call(testEmail, testPassword);

      // Assert
      expect(result.isRight, true);
      expect(result.right, testUser);
      verify(() => mockAuthRepo.login(testEmail, testPassword)).called(1);
    });

    test('should return Failure when login fails', () async {
      // Arrange
      final failure = ServerFailure(testAuthErrorMessage);
      when(() => mockAuthRepo.login(testEmail, testPassword))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call(testEmail, testPassword);

      // Assert
      expect(result.isLeft, true);
      expect(result.left, failure);
      verify(() => mockAuthRepo.login(testEmail, testPassword)).called(1);
    });

    test('should return Failure when repository throws exception', () async {
      // Arrange
      when(() => mockAuthRepo.login(testEmail, testPassword))
          .thenThrow(Exception(testErrorMessage));

      // Act & Assert
      expect(
        () => useCase.call(testEmail, testPassword),
        throwsException,
      );
      verify(() => mockAuthRepo.login(testEmail, testPassword)).called(1);
    });

    test('should pass correct email and password to repository', () async {
      // Arrange
      const customEmail = 'custom@example.com';
      const customPassword = 'CustomPass123!';
      when(() => mockAuthRepo.login(customEmail, customPassword))
          .thenAnswer((_) async => Right(testUser));

      // Act
      await useCase.call(customEmail, customPassword);

      // Assert
      verify(() => mockAuthRepo.login(customEmail, customPassword)).called(1);
    });
  });
}
