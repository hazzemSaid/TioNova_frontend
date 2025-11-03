import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/auth/domain/repo/authrepo.dart';

class ResetPasswordUseCase {
  final AuthRepo authRepo;

  ResetPasswordUseCase(this.authRepo);

  Future<Either<Failure, UserModel>> execute({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final result = await authRepo.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
    return result;
  }
}
