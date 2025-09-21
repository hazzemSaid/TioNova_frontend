import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/repoimp/FolderRepoImp.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

class CreateFolderUseCase {
  final FolderRepoImp FolderRepoimp;

  CreateFolderUseCase(this.FolderRepoimp);

  Future<Either<Failure, void>> call({
    required String title,
    String? description,
    String? category,
    required String token,
    List<String>? sharedWith,
    required Status status,
    String? icon,
    String? color,
  }) async {
    return await FolderRepoimp.createFolder(
      title: title,
      description: description,
      category: category,
      sharedWith: sharedWith,
      icon: icon,
      color: color,

      token: token,
      status: status,
    );
  }
}
