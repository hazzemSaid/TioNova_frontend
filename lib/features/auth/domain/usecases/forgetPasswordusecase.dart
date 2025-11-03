import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/domain/repo/authrepo.dart';

class ForgetPasswordUseCase {
  final AuthRepo repository;

  ForgetPasswordUseCase(this.repository);

  Future<Either<Failure, void>> call({required String email}) {
    return repository.forgetPassword(email: email);
  }
}
