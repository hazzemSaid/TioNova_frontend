import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/auth/data/models/UserModel.dart';
import 'package:tionova/features/auth/domain/repo/authrepo.dart';

class Googleauthusecase {
  final AuthRepo authRepo;
  Googleauthusecase({required this.authRepo});
  Future<Either<Failure, UserModel>> call() async {
    return await authRepo.signInWithGoogle();
  }
}
