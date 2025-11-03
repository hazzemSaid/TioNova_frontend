import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';

abstract class AuthRepo {
  Future<Either<Failure, UserModel>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserModel>> getCurrentUser();
  Future<Either<Failure, void>> register(
    String email,
    String username,
    String password,
  );
  Future<Either<Failure, UserModel>> login(String email, String password);
  Future<Either<Failure, UserModel>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });
  Future<Either<Failure, UserModel>> verifyEmail(String email, String code);
  Future<Either<Failure, void>> forgetPassword({required String email});
  Future<Either<Failure, void>> verifyCode({
    required String email,
    required String code,
  });
}
