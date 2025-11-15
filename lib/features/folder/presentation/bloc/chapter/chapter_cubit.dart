import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/core/utils/safe_emit.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/core/services/summary_cache_service.dart';
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
  }) : super(ChapterInitial());
  final Getnotesbychapteridusecase getNotesByChapterIdUseCase;
  final Addnoteusecase addNoteUseCase;
  final Deletenoteusecase deleteNoteUseCase;
  final CreateMindmapUseCase createMindmapUseCase;
  final GetChaptersUseCase getChaptersUseCase;
  final CreateChapterUseCase createChapterUseCase;
  final GetChapterContentPdfUseCase getChapterContentPdfUseCase;
  final GenerateSummaryUseCase generateSummaryUseCase;
  StreamSubscription<SSEModel>? _chapterCreationSubscription;
  void getChapters({required String folderId}) async {
    safeEmit(ChapterLoading());
    final result = await getChaptersUseCase(folderId: folderId);
    result.fold(
      (failure) => safeEmit(ChapterError(failure)),
      (chapters) => safeEmit(ChapterLoaded(chapters)),
    );
  }

  void createChapter({
    required String title,
    required String description,
    required String folderId,
    required FileData file,
  }) async {
    safeEmit(CreateChapterLoading());
    final result = await createChapterUseCase(
      title: title,
      description: description,
      folderId: folderId,
      file: file,
    );
    result.fold(
      (failure) {
        safeEmit(CreateChapterError(failure));
        unsubscribeFromChapterCreationProgress();
      },
      (_) {
        if (_chapterCreationSubscription == null) {
          safeEmit(const CreateChapterSuccess());
        }
      },
    );
  }

  void subscribeToChapterCreationProgress({required String userId}) {
    final sseUrl = '$baseUrl/sse/subscribe?userId=$userId';
    _chapterCreationSubscription?.cancel();
    _chapterCreationSubscription =
        SSEClient.subscribeToSSE(
          url: sseUrl,
          method: SSERequestType.GET,
          header: const {},
        ).listen(
          _handleChapterCreationEvent,
          onError: (error) {
            unsubscribeFromChapterCreationProgress();
            if (!isClosed) {
              safeEmit(
                const CreateChapterError(
                  ServerFailure('Lost connection to creation progress stream'),
                ),
              );
            }
          },
        );
  }

  void unsubscribeFromChapterCreationProgress() {
    _chapterCreationSubscription?.cancel();
    _chapterCreationSubscription = null;
  }

  void _handleChapterCreationEvent(SSEModel event) {
    if (isClosed || event.data == null || event.data!.isEmpty) return;

    try {
      final decodedPayload = json.decode(event.data!);
      if (decodedPayload is! Map<String, dynamic>) return;

      if (!decodedPayload.containsKey('progress') ||
          !decodedPayload.containsKey('message')) {
        return;
      }

      final num? rawProgress = decodedPayload['progress'] as num?;
      final int? progressValue = rawProgress != null
          ? rawProgress.clamp(0, 100).toInt()
          : null;
      if (progressValue == null) return;
      final message = decodedPayload['message'] as String? ?? '';
      final chapterId = decodedPayload['chapterId'] as String?;

      ChapterModel? chapter;
      if (decodedPayload['chapter'] != null) {
        chapter = ChapterModel.fromJson(decodedPayload['chapter']);
      }

      safeEmit(
        CreateChapterProgress(
          progress: progressValue,
          message: message,
          chapterId: chapterId,
          chapter: chapter,
        ),
      );

      if (progressValue >= 100 && chapter != null) {
        safeEmit(CreateChapterSuccess(chapter: chapter));
        unsubscribeFromChapterCreationProgress();
      }
    } catch (_) {
      // Ignore malformed SSE payloads silently
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
