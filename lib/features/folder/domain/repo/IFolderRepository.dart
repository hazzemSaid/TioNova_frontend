import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/data/models/ShareWithmodel.dart';

abstract class IFolderRepository {
  //createfolder , search folder , get all folder
  Future<Either<Failure, void>> createFolder({
    required String title,
    String? description,
    String? category,
    List<String>? sharedWith,
    required Status status,
    String? icon,
    String? color,
  });
  Future<Either<Failure, List<Foldermodel>>> searchFolders(String query);
  Future<Either<Failure, List<Foldermodel>>> getAllFolders();
  Future<Either<Failure, void>> deletefolder({required String id});
  Future<Either<Failure, Foldermodel>> updatefolder({
    required String id,
    required String title,
    String? description,
    List<String>? sharedWith,
    required Status status,
    String? icon,
    String? color,
  });
  Future<Either<Failure, List<ShareWithmodel>>> getAvailableUsersForShare({
    required String query,
  });
}

enum Status { public, private, share }
