import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/auth/domain/repo/authrepo.dart';

class VerifyEmailUseCase {
  final AuthRepo authRepo;

  VerifyEmailUseCase(this.authRepo);

  Future<Either<Failure, UserModel>> call(String email) async {
    return await authRepo.verifyEmail(email);
  }
}
