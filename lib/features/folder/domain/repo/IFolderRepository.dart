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
    required String token,
    List<String>? sharedWith,
    required Status status,
    String? icon,
    String? color,
  });
  Future<Either<Failure, List<Foldermodel>>> searchFolders(String query);
  Future<Either<Failure, List<Foldermodel>>> getAllFolders({
    required String token,
  });
  Future<Either<Failure, void>> deletefolder({
    required String id,
    required String token,
  });
  Future<Either<Failure, Foldermodel>> updatefolder({
    required String id,
    required String title,
    String? description,
    required String token,
    List<String>? sharedWith,
    required Status status,
    String? icon,
    String? color,
  });
  Future<Either<Failure, List<ShareWithmodel>>> getAvailableUsersForShare({
    required String query,
    required String token,
  });
}

enum Status { public, private, share }
