import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:tionova/core/errors/failure.dart';
// import 'package:tionova/core/services/firebase_realtime_service.dart';
import 'package:tionova/core/services/summary_cache_service.dart';
import 'package:tionova/core/utils/safe_emit.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/FileDataModel.dart';
import 'package:tionova/features/folder/data/models/NoteModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/data/models/mindmapmodel.dart';
import 'package:tionova/features/folder/domain/usecases/AddnoteUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/CreateChapterUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/DeleteChapterUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/DeleteNoteUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GenerateSummaryUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetChaperContentPdfUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetChapterSummaryUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetChaptersUserCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetMindmapUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetNotesByChapterIdUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/UpdateChapterUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/UpdateNoteUseCase.dart';

import '../../../domain/usecases/createMindmapUseCase.dart';

part 'chapter_state.dart';

class ChapterCubit extends Cubit<ChapterState> {
  ChapterCubit({
    required this.generateSummaryUseCase,
    required this.getChaptersUseCase,
    required this.createChapterUseCase,
    required this.getChapterContentPdfUseCase,
    required this.createMindmapUseCase,
    required this.getNotesByChapterIdUseCase,
    required this.addNoteUseCase,
    required this.deleteNoteUseCase,
    required this.updateNoteUseCase,
    // required this.firebaseService,
    required this.getMindmapUseCase,
    required this.getChapterSummaryUseCase,
    required this.updateChapterUseCase,
    required this.deleteChapterUseCase,
  }) : super(ChapterInitial());
  final Getnotesbychapteridusecase getNotesByChapterIdUseCase;
  final Addnoteusecase addNoteUseCase;
  final Deletenoteusecase deleteNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final CreateMindmapUseCase createMindmapUseCase;
  final GetChaptersUseCase getChaptersUseCase;
  final CreateChapterUseCase createChapterUseCase;
  final GetChapterContentPdfUseCase getChapterContentPdfUseCase;
  final GenerateSummaryUseCase generateSummaryUseCase;
  final GetMindmapUseCase getMindmapUseCase;
  final GetChapterSummaryUseCase getChapterSummaryUseCase;
  final UpdateChapterUseCase updateChapterUseCase;
  final DeleteChapterUseCase deleteChapterUseCase;
  // final FirebaseRealtimeService firebaseService;
  // StreamSubscription<Map<String, dynamic>>? _firebaseSubscription;
  void getChapters({required String folderId}) async {
    safeEmit(ChapterLoading());
    final result = await getChaptersUseCase(folderId: folderId);
    result.fold(
      (failure) => safeEmit(ChapterError(failure)),
      (chapters) => safeEmit(ChapterLoaded(chapters)),
    );
  }

  // Helper to get current chapters from state
  List<ChapterModel>? get currentChapters => state.chapters;

  void createChapter({
    required String title,
    required String description,
    required String folderId,
    required FileData file,
  }) async {
    print('🔵 [ChapterCubit] createChapter() called');
    print('📝 Title: $title, FolderId: $folderId, File: ${file.filename}');

    final chapters = currentChapters; // Capture before emitting
    print('📚 Current chapters count: ${chapters?.length ?? 0}');

    safeEmit(CreateChapterLoading(chapters: chapters));
    print('✅ [ChapterCubit] Emitted CreateChapterLoading');

    try {
      print('🚀 [ChapterCubit] Calling createChapterUseCase...');
      final result =
          await createChapterUseCase(
            title: title,
            description: description,
            folderId: folderId,
            file: file,
          ).timeout(
            const Duration(seconds: 120), // Increased for large PDF processing
            onTimeout: () {
              print('⏱️ [ChapterCubit] Timeout in createChapterUseCase');
              unsubscribeFromChapterCreationProgress();
              return Left(
                ServerFailure('Request timed out. Please try again.'),
              );
            },
          );

      print('📦 [ChapterCubit] UseCase returned result');
      result.fold(
        (failure) {
          print('❌ [ChapterCubit] CreateChapter failed: ${failure.toString()}');
          safeEmit(CreateChapterError(failure, chapters: chapters));
          unsubscribeFromChapterCreationProgress();
        },
        (_) {
          print('✅ [ChapterCubit] CreateChapter API success');
          // Success - let SSE handle completion or emit immediately if no SSE
          // if (_firebaseSubscription == null) {
          //   print(
          //     '⚠️ [ChapterCubit] No SSE subscription, emitting success immediately',
          //   );
          //   safeEmit(CreateChapterSuccess(chapters: chapters));
          // } else {
          //   print(
          //     '✅ [ChapterCubit] SSE subscription active, waiting for events',
          //   );
          // }
        },
      );
    } catch (e) {
      // Catch any unexpected errors
      print('💥 [ChapterCubit] Exception in createChapter: $e');
      print('Stack trace: ${StackTrace.current}');
      unsubscribeFromChapterCreationProgress();
      safeEmit(
        CreateChapterError(
          ServerFailure('Unexpected error: $e'),
          chapters: chapters,
        ),
      );
    }
  }

  /// Subscribe to Firebase Realtime Database for chapter creation progress
  /// Backend writes to: /chapter-creation/{userId}
  void subscribeToChapterCreationProgress({required String userId}) {
    print('🔥 [ChapterCubit] Subscribing to Firebase for user: $userId');

    // _firebaseSubscription?.cancel();
    // _firebaseSubscription = firebaseService
    // .listenToChapterCreation(userId)
    // .listen(
    // _handleFirebaseUpdate,
    onError:
    (error) {
      print('❌ [ChapterCubit] Firebase error: $error');
      unsubscribeFromChapterCreationProgress();
      if (!isClosed) {
        safeEmit(
          CreateChapterError(
            ServerFailure('Lost connection to creation progress'),
            chapters: currentChapters,
          ),
        );
      }
    };
    // );
  }

  /// Unsubscribe from Firebase chapter creation progress
  void unsubscribeFromChapterCreationProgress() {
    print('🔥 [ChapterCubit] Unsubscribing from Firebase');
    // _firebaseSubscription?.cancel();
    // _firebaseSubscription = null;
  }

  /// Handle Firebase Realtime Database updates for chapter creation
  void _handleFirebaseUpdate(Map<String, dynamic> data) {
    if (isClosed || data.isEmpty) return;

    try {
      final progress = (data['progress'] as num?)?.toInt() ?? 0;
      final message = data['message'] as String? ?? '';
      final chapterId = data['chapterId'] as String?;

      print('🔥 [ChapterCubit] Firebase update: $progress% - $message');

      ChapterModel? chapter;
      if (data['chapter'] != null) {
        chapter = ChapterModel.fromJson(
          Map<String, dynamic>.from(data['chapter'] as Map),
        );
      }

      final chapters = currentChapters; // Preserve current chapters

      safeEmit(
        CreateChapterProgress(
          progress: progress,
          message: message,
          chapterId: chapterId,
          chapter: chapter,
          chapters: chapters,
        ),
      );

      // When complete, emit success and cleanup
      if (progress >= 100) {
        print('✅ [ChapterCubit] Chapter creation complete!');
        // Emit success even if chapter is null to unblock UI
        safeEmit(CreateChapterSuccess(chapter: chapter, chapters: chapters));
        unsubscribeFromChapterCreationProgress();

        // Clear Firebase data
        // final authState = getIt<AuthCubit>().state;
        // if (authState is AuthSuccess) {
        //   firebaseService.clearChapterCreation(authState.user.id);
        // }
      }
    } catch (e) {
      print('❌ [ChapterCubit] Error parsing Firebase data: $e');
      // Don't emit error for parse failures, just log
    }
  }

  void getChapterContentPdf({
    required String chapterId,
    bool forDownload = false, // Add flag to indicate if this is for download
  }) async {
    final chapters = currentChapters;
    safeEmit(GetChapterContentPdfLoading(chapters: chapters));
    final result = await getChapterContentPdfUseCase(chapterId: chapterId);
    result.fold(
      (failure) => safeEmit(
        GetChapterContentPdfError(
          failure,
          forDownload: forDownload,
          chapters: chapters,
        ),
      ),
      (pdfData) => safeEmit(
        GetChapterContentPdfSuccess(
          pdfData,
          forDownload: forDownload,
          chapters: chapters,
        ),
      ),
    );
  }

  void generateSummary({
    required String chapterId,
    String? chapterTitle,
    bool forceRegenerate = false,
  }) async {
    print('🚀 DEBUG: ChapterCubit.generateSummary called');
    print('📄 Chapter ID: $chapterId');
    print('📝 Chapter Title: $chapterTitle');
    print('🔄 Force Regenerate: $forceRegenerate');

    final chapters = currentChapters;

    // Check if we have cached summary and it's not expired
    if (!forceRegenerate && SummaryCacheService.isSummaryCached(chapterId)) {
      print('💾 Found cached summary for chapter');
      final cachedData = SummaryCacheService.getCachedSummaryWithMetadata(
        chapterId,
      );
      if (cachedData != null) {
        print('✅ Emitting cached summary');
        emit(
          SummaryCachedFound(
            cachedData.summaryData,
            cachedData.cacheAge,
            chapters: chapters,
          ),
        );
        return;
      }
    }

    // Generate new summary or regenerate
    if (forceRegenerate) {
      print('🔄 Emitting SummaryRegenerateLoading');
      emit(SummaryRegenerateLoading(chapters: chapters));
    } else {
      print('🔄 Emitting GenerateSummaryLoading');
      emit(GenerateSummaryLoading(chapters: chapters));
    }

    print('📡 Calling generateSummaryUseCase...');
    final result = await generateSummaryUseCase(chapterId: chapterId);

    print('📥 UseCase returned result');
    result.fold(
      (failure) {
        print('❌ UseCase failed: ${failure.errMessage}');
        safeEmit(GenerateSummaryError(failure, chapters: chapters));
      },
      (summaryResponse) async {
        print('✅ UseCase success - SummaryResponse received');
        print(
          '📊 Summary structure: ${summaryResponse.success ? "Valid" : "Invalid"}',
        );
        print('💬 API Message: ${summaryResponse.message}');
        print(
          '🔢 Key points count: ${summaryResponse.summary.keyPoints.length}',
        );
        print(
          '� Definitions count: ${summaryResponse.summary.definitions.length}',
        );
        print(
          '🎴 Flashcards count: ${summaryResponse.summary.flashcards.length}',
        );

        try {
          final summaryData = summaryResponse.summary;
          print('✅ Using parsed SummaryModel from API');

          // Cache the successful summary
          print('💾 Caching summary...');
          await SummaryCacheService.cacheSummary(
            chapterId,
            summaryData,
            chapterTitle: chapterTitle,
          );

          if (forceRegenerate) {
            print('🔄 Emitting SummaryRegenerateSuccess');
            safeEmit(SummaryRegenerateSuccess(summaryData, chapters: chapters));
          } else {
            print('✅ Emitting GenerateSummaryStructuredSuccess');
            safeEmit(
              GenerateSummaryStructuredSuccess(summaryData, chapters: chapters),
            );
          }
        } catch (e) {
          // If there's any issue with the parsed data, log it
          print('⚠️ Error processing summary data: $e');
          safeEmit(
            GenerateSummaryError(
              ServerFailure('Failed to process summary data: $e'),
              chapters: chapters,
            ),
          );
        }
      },
    );
  }

  void checkCachedSummary({required String chapterId}) async {
    if (SummaryCacheService.isSummaryCached(chapterId)) {
      final cachedData = SummaryCacheService.getCachedSummaryWithMetadata(
        chapterId,
      );
      if (cachedData != null) {
        safeEmit(
          SummaryCachedFound(
            cachedData.summaryData,
            cachedData.cacheAge,
            chapters: currentChapters,
          ),
        );
      }
    }
  }

  void regenerateSummary({
    required String chapterId,
    String? chapterTitle,
  }) async {
    generateSummary(
      chapterId: chapterId,
      chapterTitle: chapterTitle,
      forceRegenerate: true,
    );
  }

  void createMindmap({required String chapterId}) async {
    final chapters = currentChapters;
    safeEmit(CreateMindmapLoading(chapters: chapters));
    final result = await createMindmapUseCase(chapterId: chapterId);
    result.fold(
      (failure) => safeEmit(CreateMindmapError(failure, chapters: chapters)),
      (mindmap) => safeEmit(CreateMindmapSuccess(mindmap, chapters: chapters)),
    );
  }

  void getMindmap({required String chapterId}) async {
    final chapters = currentChapters;
    safeEmit(CreateMindmapLoading(chapters: chapters)); // Reuse loading state
    final result = await getMindmapUseCase(chapterId: chapterId);
    result.fold(
      (failure) => safeEmit(CreateMindmapError(failure, chapters: chapters)),
      (mindmap) => safeEmit(
        CreateMindmapSuccess(mindmap, chapters: chapters),
      ), // Reuse success state
    );
  }

  void getChapterSummary({required String chapterId}) async {
    final chapters = currentChapters;
    safeEmit(GenerateSummaryLoading(chapters: chapters)); // Reuse loading state
    final result = await getChapterSummaryUseCase(chapterId: chapterId);
    result.fold(
      (failure) => safeEmit(GenerateSummaryError(failure, chapters: chapters)),
      (summaryResponse) {
        if (summaryResponse.success) {
          safeEmit(
            GenerateSummaryStructuredSuccess(
              summaryResponse.summary,
              chapters: chapters,
            ),
          );
        } else {
          safeEmit(
            GenerateSummaryError(
              ServerFailure(summaryResponse.message),
              chapters: chapters,
            ),
          );
        }
      },
    );
  }

  void getNotesByChapterId({required String chapterId}) async {
    final chapters = currentChapters;
    safeEmit(GetNotesByChapterIdLoading(chapters: chapters));
    final result = await getNotesByChapterIdUseCase(chapterId: chapterId);
    result.fold(
      (failure) =>
          safeEmit(GetNotesByChapterIdError(failure, chapters: chapters)),
      (notes) =>
          safeEmit(GetNotesByChapterIdSuccess(notes, chapters: chapters)),
    );
  }

  void addNote({
    required String title,
    required String chapterId,
    required Map<String, dynamic> rawData,
  }) async {
    final chapters = currentChapters;
    safeEmit(AddNoteLoading(chapters: chapters));
    final result = await addNoteUseCase(
      title: title,
      chapterId: chapterId,
      rawData: rawData,
    );
    result.fold(
      (failure) => safeEmit(AddNoteError(failure, chapters: chapters)),
      (note) => safeEmit(AddNoteSuccess(note, chapters: chapters)),
    );
  }

  void deleteNote({required String noteId, required String chapterId}) async {
    final chapters = currentChapters;
    safeEmit(DeleteNoteLoading(chapters: chapters));
    final result = await deleteNoteUseCase(noteId: noteId);
    result.fold(
      (failure) => safeEmit(DeleteNoteError(failure, chapters: chapters)),
      (_) {
        safeEmit(DeleteNoteSuccess(chapters: chapters));
        getNotesByChapterId(chapterId: chapterId);
      },
    );
  }

  void updateNote({
    required String noteId,
    required String chapterId,
    String? title,
    Map<String, dynamic>? rawData,
  }) async {
    final chapters = currentChapters;
    safeEmit(UpdateNoteLoading(chapters: chapters));
    final result = await updateNoteUseCase(
      noteId: noteId,
      title: title,
      rawData: rawData,
    );
    result.fold(
      (failure) => safeEmit(UpdateNoteError(failure, chapters: chapters)),
      (note) {
        safeEmit(UpdateNoteSuccess(note, chapters: chapters));
        // Refresh the notes list after successful update
        getNotesByChapterId(chapterId: chapterId);
      },
    );
  }

  void updateChapter({
    required String chapterId,
    required String title,
    required String description,
    required String folderId,
  }) async {
    print('🔄 [ChapterCubit] updateChapter() called');
    print('📝 Chapter ID: $chapterId, Title: $title, FolderId: $folderId');

    final chapters = currentChapters;
    safeEmit(UpdateChapterLoading(chapters: chapters));

    final result = await updateChapterUseCase(
      chapterId: chapterId,
      title: title,
      description: description,
      folderId: folderId,
    );

    result.fold(
      (failure) {
        print('❌ [ChapterCubit] updateChapter failed: ${failure.errMessage}');
        safeEmit(UpdateChapterError(failure, chapters: chapters));
      },
      (_) {
        print('✅ [ChapterCubit] updateChapter success - refreshing chapters');
        safeEmit(UpdateChapterSuccess(chapters: chapters));
        // Refresh the chapters list to get updated data
        getChapters(folderId: folderId);
      },
    );
  }

  void deleteChapter({
    required String chapterId,
    required String folderId,
  }) async {
    print('🗑️ [ChapterCubit] deleteChapter() called for chapter: $chapterId');
    final chapters = currentChapters;
    safeEmit(DeleteChapterLoading(chapters: chapters));

    final result = await deleteChapterUseCase(chapterId: chapterId);

    result.fold(
      (failure) {
        print('❌ [ChapterCubit] deleteChapter failed: ${failure.errMessage}');
        safeEmit(DeleteChapterError(failure, chapters: chapters));
      },
      (_) {
        print('✅ [ChapterCubit] deleteChapter success - refreshing chapters');
        safeEmit(DeleteChapterSuccess(chapters: chapters));
        // Refresh the chapters list to get updated data
        getChapters(folderId: folderId);
      },
    );
  }

  @override
  Future<void> close() {
    unsubscribeFromChapterCreationProgress();
    return super.close();
  }
}
