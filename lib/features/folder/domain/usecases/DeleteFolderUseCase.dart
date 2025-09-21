import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

class DeleteFolderUseCase {
  final IFolderRepository repository;

  DeleteFolderUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String id,
    required String token,
  }) => repository.deletefolder(id: id, token: token);
}
