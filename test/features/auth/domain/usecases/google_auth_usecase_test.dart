// Test for Google Auth UseCase
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/domain/usecases/googleauthusecase.dart';

import '../../../../helpers/mock_dependencies.dart';
import '../../../../helpers/test_data.dart';

void main() {
  late Googleauthusecase useCase;
  late MockAuthRepo mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepo();
    useCase = Googleauthusecase(authRepo: mockAuthRepo);
  });

  group('Googleauthusecase', () {
    test('should return UserModel when Google sign-in is successful', () async {
      // Arrange
      when(() => mockAuthRepo.signInWithGoogle())
          .thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight, true);
      expect(result.right, testUser);
      verify(() => mockAuthRepo.signInWithGoogle()).called(1);
    });

    test('should return Failure when Google sign-in fails', () async {
      // Arrange
      final failure = ServerFailure('Google sign-in cancelled');
      when(() => mockAuthRepo.signInWithGoogle())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft, true);
      expect(result.left, failure);
      verify(() => mockAuthRepo.signInWithGoogle()).called(1);
    });

    test('should return Failure when repository throws exception', () async {
      // Arrange
      when(() => mockAuthRepo.signInWithGoogle())
          .thenThrow(Exception(testErrorMessage));

      // Act & Assert
      expect(
        () => useCase.call(),
        throwsException,
      );
      verify(() => mockAuthRepo.signInWithGoogle()).called(1);
    });

    test('should handle network errors properly', () async {
      // Arrange
      final failure = ServerFailure(testNetworkErrorMessage);
      when(() => mockAuthRepo.signInWithGoogle())
          .thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft, true);
      expect(result.left.errMessage, testNetworkErrorMessage);
      verify(() => mockAuthRepo.signInWithGoogle()).called(1);
    });
  });
}
