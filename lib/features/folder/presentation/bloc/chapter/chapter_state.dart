part of 'chapter_cubit.dart';

abstract class ChapterState extends Equatable {
  const ChapterState();

  @override
  List<Object?> get props => [];
}

class ChapterInitial extends ChapterState {}

class ChapterLoading extends ChapterState {}

class ChapterLoaded extends ChapterState {
  final List<ChapterModel> chapters;
  const ChapterLoaded(this.chapters);
  @override
  List<Object?> get props => [chapters];
}

class ChapterError extends ChapterState {
  final Failure message;
  const ChapterError(this.message);
  @override
  List<Object?> get props => [message];
}

class CreateChapterLoading extends ChapterState {
  final List<ChapterModel>? chapters;
  const CreateChapterLoading({this.chapters});

  @override
  List<Object?> get props => []; // Empty - just preserves chapters, no identity
}

class CreateChapterProgress extends ChapterState {
  final int progress;
  final String message;
  final String? chapterId;
  final ChapterModel? chapter;
  final List<ChapterModel>? chapters;

  const CreateChapterProgress({
    required this.progress,
    required this.message,
    this.chapterId,
    this.chapter,
    this.chapters,
  });

  @override
  List<Object?> get props => [progress, message, chapterId, chapter]; // Exclude chapters from comparison
}

class CreateChapterSuccess extends ChapterState {
  final ChapterModel? chapter;
  final List<ChapterModel>? chapters;
  const CreateChapterSuccess({this.chapter, this.chapters});

  @override
  List<Object?> get props => [chapter]; // Exclude chapters from comparison
}

class CreateChapterError extends ChapterState {
  final Failure message;
  final List<ChapterModel>? chapters;
  const CreateChapterError(this.message, {this.chapters});
  @override
  List<Object?> get props => [message]; // Exclude chapters from comparison
}

class GetChapterContentPdfLoading extends ChapterState {}

class GetChapterContentPdfSuccess extends ChapterState {
  final Uint8List pdfData;
  final bool forDownload;
  const GetChapterContentPdfSuccess(this.pdfData, {this.forDownload = false});
  @override
  List<Object?> get props => [pdfData, forDownload];
}

class GetChapterContentPdfError extends ChapterState {
  final Failure message;
  final bool forDownload;
  const GetChapterContentPdfError(this.message, {this.forDownload = false});
  @override
  List<Object?> get props => [message, forDownload];
}

class GenerateSummaryLoading extends ChapterState {}

class GenerateSummarySuccess extends ChapterState {
  final String summary;
  const GenerateSummarySuccess(this.summary);
  @override
  List<Object?> get props => [summary];
}

class GenerateSummaryStructuredSuccess extends ChapterState {
  final SummaryModel summaryData;
  const GenerateSummaryStructuredSuccess(this.summaryData);
  @override
  List<Object?> get props => [summaryData];
}

class GenerateSummaryError extends ChapterState {
  final Failure message;
  const GenerateSummaryError(this.message);
  @override
  List<Object?> get props => [message];
}

class SummaryCachedFound extends ChapterState {
  final SummaryModel summaryData;
  final String cacheAge;
  const SummaryCachedFound(this.summaryData, this.cacheAge);
  @override
  List<Object?> get props => [summaryData, cacheAge];
}

class SummaryRegenerateLoading extends ChapterState {}

class SummaryRegenerateSuccess extends ChapterState {
  final SummaryModel summaryData;
  const SummaryRegenerateSuccess(this.summaryData);
  @override
  List<Object?> get props => [summaryData];
}

class CreateMindmapLoading extends ChapterState {}

class CreateMindmapSuccess extends ChapterState {
  final Mindmapmodel mindmap;
  const CreateMindmapSuccess(this.mindmap);
  @override
  List<Object?> get props => [];
}

class CreateMindmapError extends ChapterState {
  final Failure message;
  const CreateMindmapError(this.message);
  @override
  List<Object?> get props => [message];
}

class GetNotesByChapterIdLoading extends ChapterState {}

class GetNotesByChapterIdSuccess extends ChapterState {
  final List<Notemodel> notes;
  const GetNotesByChapterIdSuccess(this.notes);
  @override
  List<Object?> get props => [notes];
}

class GetNotesByChapterIdError extends ChapterState {
  final Failure message;
  const GetNotesByChapterIdError(this.message);
  @override
  List<Object?> get props => [message];
}

class AddNoteLoading extends ChapterState {}

class AddNoteSuccess extends ChapterState {
  final Notemodel note;
  const AddNoteSuccess(this.note);
  @override
  List<Object?> get props => [note];
}

class AddNoteError extends ChapterState {
  final Failure message;
  const AddNoteError(this.message);
  @override
  List<Object?> get props => [message];
}

class DeleteNoteLoading extends ChapterState {}

class DeleteNoteSuccess extends ChapterState {}

class DeleteNoteError extends ChapterState {
  final Failure message;
  const DeleteNoteError(this.message);
  @override
  List<Object?> get props => [message];
}
