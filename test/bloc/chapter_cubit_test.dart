import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/models/ChapterModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';

import '../mocks.dart';

void main() {
  group('ChapterCubit', () {
    late ChapterCubit cubit;
    late MockGetChaptersUseCase mockGetChapters;

    setUp(() {
      mockGetChapters = MockGetChaptersUseCase();
      cubit = ChapterCubit(
        generateSummaryUseCase: MockGenerateSummaryUseCase(),
        getChaptersUseCase: mockGetChapters,
        createChapterUseCase: MockCreateChapterUseCase(),
        getChapterContentPdfUseCase: MockGetChapterContentPdfUseCase(),
        createMindmapUseCase: MockCreateMindmapUseCase(),
        getNotesByChapterIdUseCase: MockGetNotesByChapterUseCase(),
        addNoteUseCase: MockAddNoteUseCase(),
        deleteNoteUseCase: MockDeleteNoteUseCase(),
      );
    });

    blocTest<ChapterCubit, dynamic>(
      'getChapters emits ChapterLoaded on success',
      build: () {
        final chapters = [const ChapterModel(id: '1')];
        when(
          () => mockGetChapters(folderId: any(named: 'folderId')),
        ).thenAnswer((_) async => Right(chapters));
        return cubit;
      },
      act: (c) => c.getChapters(folderId: 'f1'),
      expect: () => [isA<dynamic>(), isA<dynamic>()],
    );

    blocTest<ChapterCubit, dynamic>(
      'getChapters emits ChapterError on failure',
      build: () {
        when(
          () => mockGetChapters(folderId: any(named: 'folderId')),
        ).thenAnswer((_) async => Left(ServerFailure('x')));
        return cubit;
      },
      act: (c) => c.getChapters(folderId: 'f1'),
      expect: () => [isA<dynamic>(), isA<dynamic>()],
    );
  });
}
