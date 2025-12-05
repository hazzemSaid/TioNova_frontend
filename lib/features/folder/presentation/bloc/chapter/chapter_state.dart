part of 'chapter_cubit.dart';

abstract class ChapterState extends Equatable {
  const ChapterState();

  List<ChapterModel>? get chapters => null;

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
  @override
  final List<ChapterModel>? chapters;
  const ChapterError(this.message, {this.chapters});
  @override
  List<Object?> get props => [message, chapters];
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

class GetChapterContentPdfLoading extends ChapterState {
  @override
  final List<ChapterModel>? chapters;
  const GetChapterContentPdfLoading({this.chapters});
  @override
  List<Object?> get props => [chapters];
}

class GetChapterContentPdfSuccess extends ChapterState {
  final Uint8List pdfData;
  final bool forDownload;
  @override
  final List<ChapterModel>? chapters;
  const GetChapterContentPdfSuccess(
    this.pdfData, {
    this.forDownload = false,
    this.chapters,
  });
  @override
  List<Object?> get props => [pdfData, forDownload, chapters];
}

class GetChapterContentPdfError extends ChapterState {
  final Failure message;
  final bool forDownload;
  @override
  final List<ChapterModel>? chapters;
  const GetChapterContentPdfError(
    this.message, {
    this.forDownload = false,
    this.chapters,
  });
  @override
  List<Object?> get props => [message, forDownload, chapters];
}

class GenerateSummaryLoading extends ChapterState {
  @override
  final List<ChapterModel>? chapters;
  const GenerateSummaryLoading({this.chapters});
  @override
  List<Object?> get props => [chapters];
}

class GenerateSummarySuccess extends ChapterState {
  final String summary;
  @override
  final List<ChapterModel>? chapters;
  const GenerateSummarySuccess(this.summary, {this.chapters});
  @override
  List<Object?> get props => [summary, chapters];
}

class GenerateSummaryStructuredSuccess extends ChapterState {
  final SummaryModel summaryData;
  @override
  final List<ChapterModel>? chapters;
  const GenerateSummaryStructuredSuccess(this.summaryData, {this.chapters});
  @override
  List<Object?> get props => [summaryData, chapters];
}

class GenerateSummaryError extends ChapterState {
  final Failure message;
  @override
  final List<ChapterModel>? chapters;
  const GenerateSummaryError(this.message, {this.chapters});
  @override
  List<Object?> get props => [message, chapters];
}

class SummaryCachedFound extends ChapterState {
  final SummaryModel summaryData;
  final String cacheAge;
  @override
  final List<ChapterModel>? chapters;
  const SummaryCachedFound(this.summaryData, this.cacheAge, {this.chapters});
  @override
  List<Object?> get props => [summaryData, cacheAge, chapters];
}

class SummaryRegenerateLoading extends ChapterState {
  @override
  final List<ChapterModel>? chapters;
  const SummaryRegenerateLoading({this.chapters});
  @override
  List<Object?> get props => [chapters];
}

class SummaryRegenerateSuccess extends ChapterState {
  final SummaryModel summaryData;
  @override
  final List<ChapterModel>? chapters;
  const SummaryRegenerateSuccess(this.summaryData, {this.chapters});
  @override
  List<Object?> get props => [summaryData, chapters];
}

class CreateMindmapLoading extends ChapterState {
  @override
  final List<ChapterModel>? chapters;
  const CreateMindmapLoading({this.chapters});
  @override
  List<Object?> get props => [chapters];
}

class CreateMindmapSuccess extends ChapterState {
  final Mindmapmodel mindmap;
  @override
  final List<ChapterModel>? chapters;
  const CreateMindmapSuccess(this.mindmap, {this.chapters});
  @override
  List<Object?> get props => [mindmap, chapters];
}

class CreateMindmapError extends ChapterState {
  final Failure message;
  @override
  final List<ChapterModel>? chapters;
  const CreateMindmapError(this.message, {this.chapters});
  @override
  List<Object?> get props => [message, chapters];
}

class GetNotesByChapterIdLoading extends ChapterState {
  @override
  final List<ChapterModel>? chapters;
  const GetNotesByChapterIdLoading({this.chapters});
  @override
  List<Object?> get props => [chapters];
}

class GetNotesByChapterIdSuccess extends ChapterState {
  final List<Notemodel> notes;
  @override
  final List<ChapterModel>? chapters;
  const GetNotesByChapterIdSuccess(this.notes, {this.chapters});
  @override
  List<Object?> get props => [notes, chapters];
}

class GetNotesByChapterIdError extends ChapterState {
  final Failure message;
  @override
  final List<ChapterModel>? chapters;
  const GetNotesByChapterIdError(this.message, {this.chapters});
  @override
  List<Object?> get props => [message, chapters];
}

class AddNoteLoading extends ChapterState {
  @override
  final List<ChapterModel>? chapters;
  const AddNoteLoading({this.chapters});
  @override
  List<Object?> get props => [chapters];
}

class AddNoteSuccess extends ChapterState {
  final Notemodel note;
  @override
  final List<ChapterModel>? chapters;
  const AddNoteSuccess(this.note, {this.chapters});
  @override
  List<Object?> get props => [note, chapters];
}

class AddNoteError extends ChapterState {
  final Failure message;
  @override
  final List<ChapterModel>? chapters;
  const AddNoteError(this.message, {this.chapters});
  @override
  List<Object?> get props => [message, chapters];
}

class DeleteNoteLoading extends ChapterState {
  @override
  final List<ChapterModel>? chapters;
  const DeleteNoteLoading({this.chapters});
  @override
  List<Object?> get props => [chapters];
}

class DeleteNoteSuccess extends ChapterState {
  @override
  final List<ChapterModel>? chapters;
  const DeleteNoteSuccess({this.chapters});
  @override
  List<Object?> get props => [chapters];
}

class DeleteNoteError extends ChapterState {
  final Failure message;
  @override
  final List<ChapterModel>? chapters;
  const DeleteNoteError(this.message, {this.chapters});
  @override
  List<Object?> get props => [message, chapters];
}

class UpdateNoteLoading extends ChapterState {
  @override
  final List<ChapterModel>? chapters;
  const UpdateNoteLoading({this.chapters});
  @override
  List<Object?> get props => [chapters];
}

class UpdateNoteSuccess extends ChapterState {
  final Notemodel note;
  @override
  final List<ChapterModel>? chapters;
  const UpdateNoteSuccess(this.note, {this.chapters});
  @override
  List<Object?> get props => [note, chapters];
}

class UpdateNoteError extends ChapterState {
  final Failure message;
  @override
  final List<ChapterModel>? chapters;
  const UpdateNoteError(this.message, {this.chapters});
  @override
  List<Object?> get props => [message, chapters];
}

class UpdateChapterLoading extends ChapterState {
  @override
  final List<ChapterModel>? chapters;
  const UpdateChapterLoading({this.chapters});
  @override
  List<Object?> get props => [chapters];
}

class UpdateChapterSuccess extends ChapterState {
  @override
  final List<ChapterModel>? chapters;
  const UpdateChapterSuccess({this.chapters});
  @override
  List<Object?> get props => [chapters];
}

class UpdateChapterError extends ChapterState {
  final Failure message;
  @override
  final List<ChapterModel>? chapters;
  const UpdateChapterError(this.message, {this.chapters});
  @override
  List<Object?> get props => [message, chapters];
}

class DeleteChapterLoading extends ChapterState {
  @override
  final List<ChapterModel>? chapters;
  const DeleteChapterLoading({this.chapters});
  @override
  List<Object?> get props => [chapters];
}

class DeleteChapterSuccess extends ChapterState {
  @override
  final List<ChapterModel>? chapters;
  const DeleteChapterSuccess({this.chapters});
  @override
  List<Object?> get props => [chapters];
}

class DeleteChapterError extends ChapterState {
  final Failure message;
  @override
  final List<ChapterModel>? chapters;
  const DeleteChapterError(this.message, {this.chapters});
  @override
  List<Object?> get props => [message, chapters];
}
