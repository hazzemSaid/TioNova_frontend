import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

class GetPublicFoldersUseCase {
  final IFolderRepository folderDataSource;
  GetPublicFoldersUseCase(this.folderDataSource);

  Future<Either<Failure, List<Foldermodel>>> call() {
    return folderDataSource.getPublicFolders();
  }
}
