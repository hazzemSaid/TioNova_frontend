import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/data/AuthDataSource/Iauthdatasource.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/auth/data/services/auth_service.dart';

class Remoteauthdatasource implements IAuthDataSource {
  final Dio dio;
  final AuthService authService;
  Remoteauthdatasource({required this.dio, required this.authService});

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserModel>> login(String email, String password) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> register(
    String email,
    String username,
    String password,
  ) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() {
    return authService.signInWithGoogle();
  }

  @override
  Future<Either<Failure, void>> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserModel>> verifyEmail(String email) {
    // TODO: implement verifyEmail
    throw UnimplementedError();
  }
}
