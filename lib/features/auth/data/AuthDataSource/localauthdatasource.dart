import 'package:either_dart/either.dart';
import 'package:hive/hive.dart';
import 'package:tionova/core/errors/failure.dart' hide ServerFailure;
import 'package:tionova/core/errors/server_failure.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';

import 'ilocal_auth_data_source.dart';

class LocalAuthDataSource implements ILocalAuthDataSource {
  static const String _userBoxKey = 'user';
  final Box _storage;

  /// Creates a new instance of [LocalAuthDataSource].
  ///
  /// Requires a Hive [Box] instance for storage operations.
  const LocalAuthDataSource(this._storage);

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _storage.delete(_userBoxKey);
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(errMessage: 'Failed to sign out: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final user = _storage.get(_userBoxKey);
      if (user != null && user is UserModel) {
        return Right(user);
      }
      return Left(ServerFailure(errMessage: 'User not found'));
    } catch (e) {
      return Left(
        ServerFailure(errMessage: 'Failed to get user: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(UserModel user) async {
    try {
      await _storage.put(_userBoxKey, user);
      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure(errMessage: 'Failed to save user: ${e.toString()}'),
      );
    }
  }
}
