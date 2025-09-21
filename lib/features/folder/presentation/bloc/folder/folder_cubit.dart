// features/folder/presentation/bloc/folder/folder_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';
import 'package:tionova/features/folder/domain/usecases/CreateFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/DeleteFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetAllFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/UpdateFolderUseCase.dart';

part 'folder_state.dart';

class FolderCubit extends Cubit<FolderState> {
  FolderCubit({
    required this.getAllFolderUseCase,
    required this.createFolderUseCase,
    required this.updateFolderUseCase,
    required this.deleteFolderUseCase,
  }) : super(FolderInitial());

  final GetAllFolderUseCase getAllFolderUseCase;
  final CreateFolderUseCase createFolderUseCase;
  final UpdateFolderUseCase updateFolderUseCase;
  final DeleteFolderUseCase deleteFolderUseCase;

  Map<String, Foldermodel> _folderMap = {};
  String? _lastUpdateId;
  Map<String, dynamic>? _lastUpdateData;

  Future<void> fetchAllFolders(String token) async {
    emit(FolderLoading());
    final result = await getAllFolderUseCase(token: token);
    result.fold((failure) => emit(FolderError(failure)), (folders) {
      _folderMap = {for (var f in folders) f.id: f};
      emit(FolderLoaded(_folderMap.values.toList()));
    });
  }

  Future<void> createfolder({
    required String title,
    String? description,
    String? category,
    required String token,
    List<String>? sharedWith,
    required Status status,
    required String icon,
    required String color,
  }) async {
    emit(CreateFolderloading());
    final result = await createFolderUseCase(
      title: title,
      description: description,
      category: category,
      token: token,
      sharedWith: sharedWith ?? [],
      status: status,
      icon: icon,
      color: color,
    );
    result.fold(
      (failure) => emit(CreateFolderError(failure)),
      (_) => emit(CreateFolderSuccess()),
    );
  }

  Future<void> deletefolder({required String id, required String token}) async {
    final previousMap = Map<String, Foldermodel>.from(_folderMap);
    _folderMap.remove(id);
    emit(FolderLoaded(_folderMap.values.toList()));

    final result = await deleteFolderUseCase(id: id, token: token);
    result.fold(
      (failure) {
        _folderMap = previousMap;
        emit(FolderError(failure));
        emit(FolderLoaded(_folderMap.values.toList()));
      },
      (_) {
        emit(FolderLoaded(_folderMap.values.toList()));
      },
    );
  }

  Future<void> updatefolder({
    required String id,
    required String title,
    String? description,
    List<String>? sharedWith,
    required Status status,
    String? icon,
    String? color,
    required String token,
  }) async {
    try {
      emit(UpdateFolderLoading());

      final previousMap = Map<String, Foldermodel>.from(_folderMap);

      // Validate input
      if (title.trim().isEmpty) {
        emit(UpdateFolderError(ValidationFailure('Title cannot be empty')));
        return;
      }

      // Store update data for potential retry
      _lastUpdateId = id;
      _lastUpdateData = {
        'title': title,
        'description': description,
        'sharedWith': sharedWith,
        'status': status,
        'icon': icon,
        'color': color,
        'token': token,
      };

      // Optimistically update
      _folderMap[id] = Foldermodel(
        id: id,
        title: title,
        description: description,
        sharedWith: sharedWith,
        status: status,
        icon: icon,
        color: color,
        category: previousMap[id]?.category,
        chapterCount: previousMap[id]?.chapterCount,
        createdAt: previousMap[id]!.createdAt,
        ownerId: previousMap[id]!.ownerId,
      );
      emit(FolderLoaded(_folderMap.values.toList()));

      final result = await updateFolderUseCase(
        id: id,
        title: title,
        description: description,
        sharedWith: sharedWith,
        status: status,
        icon: icon,
        color: color,
        token: token,
      );

      result.fold(
        (failure) {
          // Revert optimistic update on failure
          _folderMap = previousMap;
          emit(UpdateFolderError(failure));
          emit(FolderLoaded(_folderMap.values.toList()));
        },
        (updatedFolderFromServer) {
          // Update with server response
          _folderMap[id] = Foldermodel(
            id: updatedFolderFromServer.id,
            title: updatedFolderFromServer.title,
            description: updatedFolderFromServer.description,
            sharedWith: updatedFolderFromServer.sharedWith,
            status: updatedFolderFromServer.status,
            icon: updatedFolderFromServer.icon,
            color: updatedFolderFromServer.color,
            category: updatedFolderFromServer.category,
            chapterCount: previousMap[id]!.chapterCount,
            createdAt: updatedFolderFromServer.createdAt,
            ownerId: updatedFolderFromServer.ownerId,
          );
          emit(UpdateFolderSuccess());
          emit(FolderLoaded(_folderMap.values.toList()));
        },
      );
    } catch (e) {
      // Handle unexpected errors
      emit(
        UpdateFolderError(
          ServerFailure('An unexpected error occurred: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> retryLastUpdate() async {
    if (_lastUpdateId != null && _lastUpdateData != null) {
      await updatefolder(
        id: _lastUpdateId!,
        title: _lastUpdateData!['title'],
        description: _lastUpdateData!['description'],
        sharedWith: _lastUpdateData!['sharedWith'],
        status: _lastUpdateData!['status'],
        icon: _lastUpdateData!['icon'],
        color: _lastUpdateData!['color'],
        token: _lastUpdateData!['token'],
      );
    }
  }
}
