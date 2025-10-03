import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart' show Failure;
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/auth/domain/repo/authrepo.dart';

class LoginUseCase {
  final AuthRepo repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserModel>> call(String email, String password) {
    return repository.login(email, password);
  }
}
