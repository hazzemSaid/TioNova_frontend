import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/domain/repo/authrepo.dart';

class VerifyCodeUseCase {
  final AuthRepo authRepo;
  VerifyCodeUseCase(this.authRepo);
  Future<Either<Failure, void>> call({
    required String email,
    required String code,
  }) {
    return authRepo.verifyCode(email: email, code: code);
  }
}
