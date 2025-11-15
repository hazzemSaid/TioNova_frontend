import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

class GetAllFolderUseCase {
  final IFolderRepository folderDataSource;
  GetAllFolderUseCase(this.folderDataSource);
  Future<Either<Failure, List<Foldermodel>>> call() {
    return folderDataSource.getAllFolders();
  }
}
