// Test for RegisterUseCase
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/domain/usecases/registerusecase.dart';

import '../../../../helpers/mock_dependencies.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late RegisterUseCase useCase;
  late MockAuthRepo mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    useCase = RegisterUseCase(mockAuthRepo);
  });

  group('RegisterUseCase', () {
    test('should return void when registration is successful', () async {
      // Arrange
      when(() => mockAuthRepo.register(testEmail, testUsername, testPassword))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase.call(testEmail, testUsername, testPassword);

      // Assert
      expect(result.isRight, true);
      verify(() => mockAuthRepo.register(testEmail, testUsername, testPassword))
          .called(1);
    });

    test('should return Failure when registration fails', () async {
      // Arrange
      final failure = ServerFailure('Email already exists');
      when(() => mockAuthRepo.register(testEmail, testUsername, testPassword))
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call(testEmail, testUsername, testPassword);

      // Assert
      expect(result.isLeft, true);
      expect(result.left, failure);
      verify(() => mockAuthRepo.register(testEmail, testUsername, testPassword))
          .called(1);
    });

    test('should return Failure when repository throws exception', () async {
      // Arrange
      when(() => mockAuthRepo.register(testEmail, testUsername, testPassword))
          .thenThrow(Exception(testErrorMessage));

      // Act & Assert
      expect(
        () => useCase.call(testEmail, testUsername, testPassword),
        throwsException,
      );
      verify(() => mockAuthRepo.register(testEmail, testUsername, testPassword))
          .called(1);
    });

    test('should pass correct registration data to repository', () async {
      // Arrange
      const customEmail = 'custom@example.com';
      const customUsername = 'customuser';
      const customPassword = 'CustomPass123!';
      when(() =>
              mockAuthRepo.register(customEmail, customUsername, customPassword))
          .thenAnswer((_) async => const Right(null));

      // Act
      await useCase.call(customEmail, customUsername, customPassword);

      // Assert
      verify(() =>
              mockAuthRepo.register(customEmail, customUsername, customPassword))
          .called(1);
    });
  });
}
