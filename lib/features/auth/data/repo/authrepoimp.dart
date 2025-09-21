import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/data/AuthDataSource/Iauthdatasource.dart';
import 'package:tionova/features/auth/data/AuthDataSource/ilocal_auth_data_source.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/auth/domain/repo/authrepo.dart';

class AuthRepoImp implements AuthRepo {
  final IAuthDataSource remoteDataSource;
  final ILocalAuthDataSource localDataSource;

  AuthRepoImp({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    // First try to get from local storage
    final localUser = await localDataSource.getCurrentUser();
    if (localUser.isRight) {
      return localUser;
    }

    // If not found locally, try remote
    final remoteUser = await remoteDataSource.getCurrentUser();
    if (remoteUser.isRight) {
      await localDataSource.saveUser(remoteUser.right);
    }
    return remoteUser;
  }

  @override
  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) async {
    final result = await remoteDataSource.login(email, password);
    if (result.isRight) {
      await localDataSource.saveUser(result.right);
    }
    return result;
  }

  @override
  Future<Either<Failure, void>> register(
    String email,
    String username,
    String password,
  ) {
    return remoteDataSource.register(email, username, password);
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email) {
    return remoteDataSource.resetPassword(email);
  }

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    final result = await remoteDataSource.signInWithGoogle();
    if (result.isRight) {
      await localDataSource.saveUser(result.right);
    }
    return result;
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    // Clear local data first
    final localSignOut = await localDataSource.signOut();
    if (localSignOut.isLeft) {
      return localSignOut;
    }

    // Then sign out from remote
    return remoteDataSource.signOut();
  }

  @override
  Future<Either<Failure, UserModel>> verifyEmail(String email) async {
    final result = await remoteDataSource.verifyEmail(email);
    if (result.isRight) {
      await localDataSource.saveUser(result.right);
    }
    return result;
  }
}
