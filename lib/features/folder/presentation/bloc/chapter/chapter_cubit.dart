import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/core/services/firebase_realtime_service.dart';
import 'package:tionova/core/services/summary_cache_service.dart';
import 'package:tionova/core/utils/safe_emit.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/FileDataModel.dart';
import 'package:tionova/features/folder/data/models/NoteModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/data/models/mindmapmodel.dart';
import 'package:tionova/features/folder/domain/usecases/AddnoteUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/CreateChapterUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/DeleteNoteUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GenerateSummaryUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetChaperContentPdfUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetChaptersUserCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetNotesByChapterIdUseCase.dart';

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
    required this.firebaseService,
  }) : super(ChapterInitial());
  final Getnotesbychapteridusecase getNotesByChapterIdUseCase;
  final Addnoteusecase addNoteUseCase;
  final Deletenoteusecase deleteNoteUseCase;
  final CreateMindmapUseCase createMindmapUseCase;
  final GetChaptersUseCase getChaptersUseCase;
  final CreateChapterUseCase createChapterUseCase;
  final GetChapterContentPdfUseCase getChapterContentPdfUseCase;
  final GenerateSummaryUseCase generateSummaryUseCase;
  final FirebaseRealtimeService firebaseService;
  StreamSubscription<Map<String, dynamic>>? _firebaseSubscription;
  void getChapters({required String folderId}) async {
    safeEmit(ChapterLoading());
    final result = await getChaptersUseCase(folderId: folderId);
    result.fold(
      (failure) => safeEmit(ChapterError(failure)),
      (chapters) => safeEmit(ChapterLoaded(chapters)),
    );
  }

  // Helper to get current chapters from state
  List<ChapterModel>? get currentChapters {
    final currentState = state;
    if (currentState is ChapterLoaded) {
      return currentState.chapters;
    } else if (currentState is CreateChapterLoading) {
      return currentState.chapters;
    } else if (currentState is CreateChapterProgress) {
      return currentState.chapters;
    } else if (currentState is CreateChapterSuccess) {
      return currentState.chapters;
    } else if (currentState is CreateChapterError) {
      return currentState.chapters;
    }
    return null;
  }

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
          if (_firebaseSubscription == null) {
            print(
              '⚠️ [ChapterCubit] No SSE subscription, emitting success immediately',
            );
            safeEmit(CreateChapterSuccess(chapters: chapters));
          } else {
            print(
              '✅ [ChapterCubit] SSE subscription active, waiting for events',
            );
          }
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

    _firebaseSubscription?.cancel();
    _firebaseSubscription = firebaseService
        .listenToChapterCreation(userId)
        .listen(
          _handleFirebaseUpdate,
          onError: (error) {
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
          },
        );
  }

  /// Unsubscribe from Firebase chapter creation progress
  void unsubscribeFromChapterCreationProgress() {
    print('🔥 [ChapterCubit] Unsubscribing from Firebase');
    _firebaseSubscription?.cancel();
    _firebaseSubscription = null;
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
    safeEmit(GetChapterContentPdfLoading());
    final result = await getChapterContentPdfUseCase(chapterId: chapterId);
    result.fold(
      (failure) => safeEmit(
        GetChapterContentPdfError(failure, forDownload: forDownload),
      ),
      (pdfData) => safeEmit(
        GetChapterContentPdfSuccess(pdfData, forDownload: forDownload),
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

    // Check if we have cached summary and it's not expired
    if (!forceRegenerate && SummaryCacheService.isSummaryCached(chapterId)) {
      print('💾 Found cached summary for chapter');
      final cachedData = SummaryCacheService.getCachedSummaryWithMetadata(
        chapterId,
      );
      if (cachedData != null) {
        print('✅ Emitting cached summary');
        emit(SummaryCachedFound(cachedData.summaryData, cachedData.cacheAge));
        return;
      }
    }

    // Generate new summary or regenerate
    if (forceRegenerate) {
      print('🔄 Emitting SummaryRegenerateLoading');
      emit(SummaryRegenerateLoading());
    } else {
      print('🔄 Emitting GenerateSummaryLoading');
      emit(GenerateSummaryLoading());
    }

    print('📡 Calling generateSummaryUseCase...');
    final result = await generateSummaryUseCase(chapterId: chapterId);

    print('📥 UseCase returned result');
    result.fold(
      (failure) {
        print('❌ UseCase failed: ${failure.errMessage}');
        safeEmit(GenerateSummaryError(failure));
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
            safeEmit(SummaryRegenerateSuccess(summaryData));
          } else {
            print('✅ Emitting GenerateSummaryStructuredSuccess');
            safeEmit(GenerateSummaryStructuredSuccess(summaryData));
          }
        } catch (e) {
          // If there's any issue with the parsed data, log it
          print('⚠️ Error processing summary data: $e');
          safeEmit(
            GenerateSummaryError(
              ServerFailure('Failed to process summary data: $e'),
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
          SummaryCachedFound(cachedData.summaryData, cachedData.cacheAge),
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
    safeEmit(CreateMindmapLoading());
    final result = await createMindmapUseCase(chapterId: chapterId);
    result.fold(
      (failure) => safeEmit(CreateMindmapError(failure)),
      (mindmap) => safeEmit(CreateMindmapSuccess(mindmap)),
    );
  }

  void getNotesByChapterId({required String chapterId}) async {
    safeEmit(GetNotesByChapterIdLoading());
    final result = await getNotesByChapterIdUseCase(chapterId: chapterId);
    result.fold(
      (failure) => safeEmit(GetNotesByChapterIdError(failure)),
      (notes) => safeEmit(GetNotesByChapterIdSuccess(notes)),
    );
  }

  void addNote({
    required String title,
    required String chapterId,
    required Map<String, dynamic> rawData,
  }) async {
    safeEmit(AddNoteLoading());
    final result = await addNoteUseCase(
      title: title,
      chapterId: chapterId,
      rawData: rawData,
    );
    result.fold(
      (failure) => safeEmit(AddNoteError(failure)),
      (note) => safeEmit(AddNoteSuccess(note)),
    );
  }

  void deleteNote({required String noteId, required String chapterId}) async {
    safeEmit(DeleteNoteLoading());
    final result = await deleteNoteUseCase(noteId: noteId);
    result.fold((failure) => safeEmit(DeleteNoteError(failure)), (_) {
      safeEmit(DeleteNoteSuccess());
      getNotesByChapterId(chapterId: chapterId);
    });
  }

  @override
  Future<void> close() {
    unsubscribeFromChapterCreationProgress();
    return super.close();
  }
}
