import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/domain/repo/authrepo.dart';

class RegisterUseCase {
  final AuthRepo authRepo;

  RegisterUseCase(this.authRepo);

  Future<Either<Failure, void>> call(
    String email,
    String username,
    String password,
  ) async {
    return await authRepo.register(email, username, password);
  }
}
