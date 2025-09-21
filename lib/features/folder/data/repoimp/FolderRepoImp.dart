import 'package:either_dart/src/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/datasources/FolderRemoteDataSource.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

class FolderRepoImp implements IFolderRepository {
  final FolderRemoteDataSource remoteDataSource;
  FolderRepoImp({required this.remoteDataSource});
  @override
  Future<Either<Failure, void>> createFolder({
    required String title,
    String? description,
    String? category,
    required String token,
    List<String>? sharedWith,
    required Status status,
    String? icon,
    String? color,
  }) {
    return remoteDataSource.createFolder(
      title: title,
      description: description,
      category: category,
      token: token,
      sharedWith: sharedWith,
      status: status,
      icon: icon,
      color: color,
    );
  }

  @override
  Future<Either<Failure, List<Foldermodel>>> getAllFolders({
    required String token,
  }) {
    return remoteDataSource.getAllFolders(token: token);
  }

  @override
  Future<Either<Failure, List<Foldermodel>>> searchFolders(String query) {
    return remoteDataSource.searchFolders(query);
  }

  @override
  Future<Either<Failure, void>> deletefolder({
    required String id,
    required String token,
  }) {
    return remoteDataSource.deletefolder(id: id, token: token);
  }

  @override
  Future<Either<Failure, Foldermodel>> updatefolder({
    required String id,
    required String title,
    String? description,
    required String token,
    List<String>? sharedWith,
    required Status status,
    String? icon,
    String? color,
  }) {
    return remoteDataSource.updatefolder(
      id: id,
      title: title,
      description: description,
      token: token,
      sharedWith: sharedWith,
      status: status,
      icon: icon,
      color: color,
    );
  }
}
