import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

class CreateFolderUseCase {
  final IFolderRepository FolderRepoimp;

  CreateFolderUseCase(this.FolderRepoimp);

  Future<Either<Failure, void>> call({
    required String title,
    String? description,
    String? category,
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

      status: status,
    );
  }
}
