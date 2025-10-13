import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/core/services/summary_cache_service.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/data/models/FileDataModel.dart';
import 'package:tionova/features/folder/data/models/SummaryModel.dart';
import 'package:tionova/features/folder/data/models/mindmapmodel.dart';
import 'package:tionova/features/folder/domain/usecases/CreateChapterUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GenerateSummaryUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetChaperContentPdfUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetChaptersUserCase.dart';

import '../../../domain/usecases/createMindmapUseCase.dart';

part 'chapter_state.dart';

class ChapterCubit extends Cubit<ChapterState> {
  ChapterCubit({
    required this.generateSummaryUseCase,
    required this.getChaptersUseCase,
    required this.createChapterUseCase,
    required this.getChapterContentPdfUseCase,
    required this.createMindmapUseCase,
  }) : super(ChapterInitial());
  final CreateMindmapUseCase createMindmapUseCase;
  final GetChaptersUseCase getChaptersUseCase;
  final CreateChapterUseCase createChapterUseCase;
  final GetChapterContentPdfUseCase getChapterContentPdfUseCase;
  final GenerateSummaryUseCase generateSummaryUseCase;
  void getChapters({required String folderId, required String token}) async {
    emit(ChapterLoading());
    final result = await getChaptersUseCase(folderId: folderId, token: token);
    result.fold(
      (failure) => emit(ChapterError(failure)),
      (chapters) => emit(ChapterLoaded(chapters)),
    );
  }

  void createChapter({
    required String title,
    required String description,
    required String folderId,
    required String token,
    required FileData file,
  }) async {
    emit(CreateChapterLoading());
    final result = await createChapterUseCase(
      title: title,
      description: description,
      folderId: folderId,
      token: token,
      file: file,
    );
    result.fold((failure) => emit(CreateChapterError(failure)), (_) {
      emit(CreateChapterSuccess());
      getChapters(folderId: folderId, token: token);
    });
  }

  void getChapterContentPdf({
    required String token,
    required String chapterId,
    bool forDownload = false, // Add flag to indicate if this is for download
  }) async {
    emit(GetChapterContentPdfLoading());
    final result = await getChapterContentPdfUseCase(
      token: token,
      chapterId: chapterId,
    );
    result.fold(
      (failure) =>
          emit(GetChapterContentPdfError(failure, forDownload: forDownload)),
      (pdfData) =>
          emit(GetChapterContentPdfSuccess(pdfData, forDownload: forDownload)),
    );
  }

  void generateSummary({
    required String token,
    required String chapterId,
    String? chapterTitle,
    bool forceRegenerate = false,
  }) async {
    print('🚀 DEBUG: ChapterCubit.generateSummary called');
    print('📄 Chapter ID: $chapterId');
    print('📝 Chapter Title: $chapterTitle');
    print('🔄 Force Regenerate: $forceRegenerate');
    print('🔑 Token present: ${token.isNotEmpty}');

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
    final result = await generateSummaryUseCase(
      token: token,
      chapterId: chapterId,
    );

    print('📥 UseCase returned result');
    result.fold(
      (failure) {
        print('❌ UseCase failed: ${failure.errMessage}');
        emit(GenerateSummaryError(failure));
      },
      (summaryResponse) async {
        print('✅ UseCase success - SummaryResponse received');
        print(
          '📊 Summary structure: ${summaryResponse.success ? "Valid" : "Invalid"}',
        );
        print('💬 API Message: ${summaryResponse.message}');
        print(
          '🔢 Key concepts count: ${summaryResponse.summary.keyConcepts.length}',
        );
        print('� Examples count: ${summaryResponse.summary.examples.length}');
        print(
          '💼 Professional implications count: ${summaryResponse.summary.professionalImplications.length}',
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
            emit(SummaryRegenerateSuccess(summaryData));
          } else {
            print('✅ Emitting GenerateSummaryStructuredSuccess');
            emit(GenerateSummaryStructuredSuccess(summaryData));
          }
        } catch (e) {
          // If there's any issue with the parsed data, log it
          print('⚠️ Error processing summary data: $e');
          emit(
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
        emit(SummaryCachedFound(cachedData.summaryData, cachedData.cacheAge));
      }
    }
  }

  void regenerateSummary({
    required String token,
    required String chapterId,
    String? chapterTitle,
  }) async {
    generateSummary(
      token: token,
      chapterId: chapterId,
      chapterTitle: chapterTitle,
      forceRegenerate: true,
    );
  }

  void createMindmap({required String token, required String chapterId}) async {
    emit(CreateMindmapLoading());
    final result = await createMindmapUseCase(
      token: token,
      chapterId: chapterId,
    );
    result.fold(
      (failure) => emit(CreateMindmapError(failure)),
      (mindmap) => emit(CreateMindmapSuccess(mindmap)),
    );
  }
}
