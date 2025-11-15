// features/folder/presentation/bloc/folder/folder_cubit.dart
import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/core/utils/safe_emit.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/data/models/ShareWithmodel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';
import 'package:tionova/features/folder/domain/usecases/CreateFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/DeleteFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetAllFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/UpdateFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/getAvailableUsersForShareUseCase.dart';

part 'folder_state.dart';

class FolderCubit extends Cubit<FolderState> {
  final Map<String, Foldermodel> _folderMap = {};
  FolderCubit({
    required this.getAllFolderUseCase,
    required this.createFolderUseCase,
    required this.updateFolderUseCase,
    required this.deleteFolderUseCase,
    required this.getAvailableUsersForShareUseCase,
  }) : super(FolderInitial());

  final GetAllFolderUseCase getAllFolderUseCase;
  final CreateFolderUseCase createFolderUseCase;
  final UpdateFolderUseCase updateFolderUseCase;
  final DeleteFolderUseCase deleteFolderUseCase;
  final GetAvailableUsersForShareUseCase getAvailableUsersForShareUseCase;

  // SSE subscription reference
  StreamSubscription<SSEModel>? _sseSubscription;

  // Call this to start listening to SSE events for folder changes
  void subscribeToFolderSse(String sseUrl) {
    // Cancel previous subscription if exists
    _sseSubscription?.cancel();
    _sseSubscription =
        SSEClient.subscribeToSSE(
          url: sseUrl,
          method: SSERequestType.GET,
          header: {},
        ).listen((event) {
          _handleSseEvent(event);
        });
  }

  // Call this to stop listening to SSE events
  void unsubscribeFromFolderSse() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
  }

  @override
  Future<void> close() {
    unsubscribeFromFolderSse();
    return super.close();
  }

  Future<void> fetchAllFolders() async {
    if (isClosed) return;
    safeEmit(FolderLoading());
    final result = await getAllFolderUseCase();
    if (isClosed) return;
    result.fold(
      (failure) {
        if (!isClosed) safeEmit(FolderError(failure));
      },
      (folders) {
        _folderMap.clear();
        for (final folder in folders) {
          _folderMap[folder.id] = folder;
        }
        if (!isClosed) safeEmit(FolderLoaded(_folderMap.values.toList()));
      },
    );
  }

  Future<void> createfolder({
    required String title,
    String? description,
    String? category,
    List<String>? sharedWith,
    required Status status,
    required String icon,
    required String color,
  }) async {
    safeEmit(CreateFolderloading());
    final result = await createFolderUseCase(
      title: title,
      description: description,
      category: category,
      sharedWith: sharedWith ?? [],
      status: status,
      icon: icon,
      color: color,
    );
    result.fold((failure) => safeEmit(CreateFolderError(failure)), (_) async {
      safeEmit(CreateFolderSuccess());
    });
  }

  Future<void> deletefolder({required String id}) async {
    // Validation check before destructive operation
    if (!_folderMap.containsKey(id)) {
      safeEmit(
        DeleteFolderError(ValidationFailure('Folder not found for deletion')),
      );
      return;
    }

    safeEmit(
      DeleteFolderLoading(_folderMap.values.toList()),
    ); // Emit loading state
    final result = await deleteFolderUseCase(id: id);
    result.fold(
      (failure) {
        safeEmit(DeleteFolderError(failure));
      },
      (_) {
        _folderMap.remove(id);
        safeEmit(DeleteFolderSuccess());
        safeEmit(FolderLoaded(_folderMap.values.toList()));
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
  }) async {
    try {
      // Validate input before operation
      if (title.trim().isEmpty) {
        safeEmit(UpdateFolderError(ValidationFailure('Title cannot be empty')));
        return;
      }

      if (!_folderMap.containsKey(id)) {
        safeEmit(
          UpdateFolderError(ValidationFailure('Folder not found for update')),
        );
        return;
      }
      int chapterCount = _folderMap[id]!.chapterCount ?? 0;
      int passedCount = _folderMap[id]!.passedCount ?? 0;
      int attemptedCount = _folderMap[id]!.attemptedCount ?? 0;

      // Emit loading state with current folders for immediate UI feedback
      safeEmit(UpdateFolderLoading(_folderMap.values.toList()));

      final result = await updateFolderUseCase(
        id: id,
        title: title,
        description: description,
        sharedWith: sharedWith,
        status: status,
        icon: icon,
        color: color,
      );

      result.fold(
        (failure) {
          safeEmit(UpdateFolderError(failure));
          // Restore folder list after error to maintain UI consistency
          safeEmit(FolderLoaded(_folderMap.values.toList()));
        },
        (updatedFolderFromServer) {
          _folderMap[updatedFolderFromServer.id] = updatedFolderFromServer
              .copyWith(
                chapterCount: chapterCount,
                passedCount: passedCount,
                attemptedCount: attemptedCount,
              );
          safeEmit(UpdateFolderSuccess());
          safeEmit(FolderLoaded(_folderMap.values.toList()));
        },
      );
    } catch (e) {
      // Handle unexpected errors and restore UI state
      safeEmit(
        UpdateFolderError(
          ServerFailure('An unexpected error occurred: ${e.toString()}'),
        ),
      );
      safeEmit(FolderLoaded(_folderMap.values.toList()));
    }
  }

  Future<void> getAvailableUsersForShare({required String query}) async {
    safeEmit(GetAvailableUsersForShareLoading());
    final result = await getAvailableUsersForShareUseCase(query: query);
    result.fold(
      (failure) => safeEmit(GetAvailableUsersForShareError(failure)),
      (users) => safeEmit(GetAvailableUsersForShareSuccess(users)),
    );
  }

  // افترض ان ده الكود داخل نفس الـ Cubit/BLoC

  // ... (متغير _folderMap موجود هنا)
  // Map<String, Folder> _folderMap = {};

  // دالة جديدة لمعالجة الأحداث القادمة من السيرفر
  void _handleSseEvent(SSEModel event) {
    if (isClosed || event.data == null || event.data!.isEmpty) return;

    try {
      final eventData = event.data is String
          ? json.decode(event.data!)
          : event.data;
      final String eventType = eventData['type'];
      final Foldermodel folder = Foldermodel.fromJson(eventData['folder']);

      // 2. حدد نوع الحدث ونفذ التعديل المناسب
      switch (eventType) {
        case 'folder_created':
        case 'folder_shared_created':
          // أضف المجلد الجديد للخريطة
          _folderMap[folder.id] = folder;
          break;
        case 'folder_updated':
        case 'folder_shared_updated':
          // حدث بيانات المجلد الموجود
          _folderMap[folder.id] = folder;
          break;
        case 'folder_deleted':
        case 'folder_shared_deleted':
          _folderMap.remove(folder.id);
          break;
        default:
        // تجاهل الأنواع غير المعروفة
      }

      // 3. أطلق state جديدة بالقائمة المحدثة
      safeEmit(FolderLoaded(_folderMap.values.toList()));
    } catch (e) {
      // يمكنك التعامل مع أخطاء فك التشفير هنا
    }
  }
}
