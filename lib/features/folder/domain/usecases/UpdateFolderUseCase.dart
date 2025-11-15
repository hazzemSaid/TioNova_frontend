import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

class UpdateFolderUseCase {
  final IFolderRepository repository;
  UpdateFolderUseCase(this.repository);

  Future<Either<Failure, Foldermodel>> call({
    required String id,
    required String title,
    String? description,
    List<String>? sharedWith,
    required Status status,
    String? icon,
    String? color,
  }) {
    return repository.updatefolder(
      id: id,
      title: title,
      description: description,
      sharedWith: sharedWith,
      status: status,
      icon: icon,
      color: color,
    );
  }
}
