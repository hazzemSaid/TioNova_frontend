import 'package:either_dart/src/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/datasources/FolderRemoteDataSource.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/data/models/ShareWithmodel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

class FolderRepoImp implements IFolderRepository {
  final FolderRemoteDataSource remoteDataSource;
  FolderRepoImp({required this.remoteDataSource});
  @override
  Future<Either<Failure, void>> createFolder({
    required String title,
    String? description,
    String? category,
    List<String>? sharedWith,
    required Status status,
    String? icon,
    String? color,
  }) {
    return remoteDataSource.createFolder(
      title: title,
      description: description,
      category: category,
      sharedWith: sharedWith,
      status: status,
      icon: icon,
      color: color,
    );
  }

  @override
  Future<Either<Failure, List<Foldermodel>>> getAllFolders() {
    return remoteDataSource.getAllFolders();
  }

  @override
  Future<Either<Failure, List<Foldermodel>>> searchFolders(String query) {
    return remoteDataSource.searchFolders(query);
  }

  @override
  Future<Either<Failure, void>> deletefolder({required String id}) {
    return remoteDataSource.deletefolder(id: id);
  }

  @override
  Future<Either<Failure, Foldermodel>> updatefolder({
    required String id,
    required String title,
    String? description,
    List<String>? sharedWith,
    required Status status,
    String? icon,
    String? color,
  }) {
    return remoteDataSource.updatefolder(
      id: id,
      title: title,
      description: description,
      sharedWith: sharedWith,
      status: status,
      icon: icon,
      color: color,
    );
  }

  @override
  Future<Either<Failure, List<ShareWithmodel>>> getAvailableUsersForShare({
    required String query,
  }) {
    return remoteDataSource.getAvailableUsersForShare(query: query);
  }

  @override
  Future<Either<Failure, List<Foldermodel>>> getPublicFolders() {
    return remoteDataSource.getPublicFolders();
  }
}
