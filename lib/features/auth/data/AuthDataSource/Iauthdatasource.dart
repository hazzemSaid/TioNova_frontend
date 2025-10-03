import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';

abstract class IAuthDataSource {
  Future<Either<Failure, UserModel>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> register(
    String email,
    String username,
    String password,
  );
  Future<Either<Failure, UserModel>> login(String email, String password);
  Future<Either<Failure, void>> resetPassword(
    String email, {
    String? newPassword,
  });
  Future<Either<Failure, UserModel>> verifyEmail(String email, String code);
  Future<Either<Failure, UserModel>> getCurrentUser();
}
