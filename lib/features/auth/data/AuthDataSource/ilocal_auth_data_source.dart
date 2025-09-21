import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';

/// A data source that handles local authentication-related operations.
/// Uses Hive for local storage to persist user session data.
abstract class ILocalAuthDataSource {
  /// Signs out the current user by removing user data from local storage.
  Future<Either<Failure, void>> signOut();

  /// Retrieves the currently authenticated user from local storage.
  /// Returns [ServerFailure] if no user is found.
  Future<Either<Failure, UserModel>> getCurrentUser();

  /// Saves user data to local storage.
  Future<Either<Failure, void>> saveUser(UserModel user);
}
