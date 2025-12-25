import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/core/utils/error_handling_utils.dart';
import 'package:tionova/features/folder/data/models/foldermodel.dart';
import 'package:tionova/features/folder/data/models/ShareWithmodel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

class FolderRemoteDataSource implements IFolderRepository {
  final Dio _dio;

  FolderRemoteDataSource(this._dio);
  @override
  Future<Either<Failure, List<Foldermodel>>> getAllFolders() async {
    try {
      final response = await _dio.get(
        '/getfolders',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return ErrorHandlingUtils.handleApiResponse<List<Foldermodel>>(
        response: response,
        onSuccess: (data) {
          return (data['folders'] as List)
              .map((folderJson) => Foldermodel.fromJson(folderJson))
              .toList();
        },
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, List<Foldermodel>>> searchFolders(String query) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> createFolder({
    required String title,
    String? description,
    String? category,
    List<String>? sharedWith,
    required Status status,
    String? color,
    String? icon,
  }) async {
    try {
      final data = {
        'title': title,
        'description': description,
        'category': category,
        'sharedWith': sharedWith,
        'status': status.toString().split('.').last,
        'icon': icon,
        'color': color,
      };

      final response = await _dio.post(
        '/createfolder',
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return ErrorHandlingUtils.handleApiResponse<void>(
        response: response,
        onSuccess: (_) => null,
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, void>> deletefolder({required String id}) async {
    try {
      final response = await _dio.delete(
        '/deletefolder/$id',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return ErrorHandlingUtils.handleApiResponse<void>(
        response: response,
        onSuccess: (_) => null,
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
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
  }) async {
    try {
      final data = {
        'folderId': id,
        'title': title,
        'description': description,
        'sharedWith': sharedWith,
        'status': status.toString().split('.').last,
        'icon': icon,
        'color': color,
      };

      print('Updating folder with data: $data');

      final response = await _dio.patch(
        '/updatefolder',
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      
      return ErrorHandlingUtils.handleApiResponse<Foldermodel>(
        response: response,
        onSuccess: (data) {
          // Parse the updated folder from the response
          if (data != null && data['folder'] != null) {
            return Foldermodel.fromJson(data['folder']);
          } else {
            throw Exception('Invalid response format');
          }
        },
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }

  @override
  Future<Either<Failure, List<ShareWithmodel>>> getAvailableUsersForShare({
    required String query,
  }) async {
    try {
      final response = await _dio.post(
        '/getAvailableUsersForShare',
        data: {'query': query},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return ErrorHandlingUtils.handleApiResponse<List<ShareWithmodel>>(
        response: response,
        onSuccess: (data) {
          return (data['results'] as List)
              .map((userJson) => ShareWithmodel.fromJson(userJson))
              .toList();
        },
      );
    } catch (error) {
      return ErrorHandlingUtils.handleDioError(error);
    }
  }

  @override
  Future<Either<Failure, List<Foldermodel>>> getPublicFolders() async {
    try {
      final response = await _dio.get(
        '/getpublicfolders',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return ErrorHandlingUtils.handleApiResponse<List<Foldermodel>>(
        response: response,
        onSuccess: (data) {
          return (data['folders'] as List)
              .map((folderJson) => Foldermodel.fromJson(folderJson))
              .toList();
        },
      );
    } catch (e) {
      return ErrorHandlingUtils.handleDioError(e);
    }
  }
}
