part of 'folder_cubit.dart';

abstract class FolderState extends Equatable {
  const FolderState();

  @override
  List<Object> get props => [];
}

class FolderInitial extends FolderState {}

class FolderLoading extends FolderState {}

class FolderLoaded extends FolderState {
  final List<Foldermodel> folders;
  const FolderLoaded(this.folders);

  @override
  List<Object> get props => [folders];
}

class FolderError extends FolderState {
  final Failure message;
  const FolderError(this.message);

  @override
  List<Object> get props => [message];
}

class CreateFolderloading extends FolderState {}

class CreateFolderSuccess extends FolderState {}

class CreateFolderError extends FolderState {
  final Failure message;
  const CreateFolderError(this.message);

  @override
  List<Object> get props => [message];
}

class DeleteFolderLoading extends FolderState {
  final List<Foldermodel> folders;
  const DeleteFolderLoading(this.folders);

  @override
  List<Object> get props => [folders];
}

class DeleteFolderSuccess extends FolderState {}

class DeleteFolderError extends FolderState {
  final Failure message;
  const DeleteFolderError(this.message);

  @override
  List<Object> get props => [message];
}

class UpdateFolderLoading extends FolderState {
  final List<Foldermodel> folders;
  const UpdateFolderLoading(this.folders);

  @override
  List<Object> get props => [folders];
}

class UpdateFolderSuccess extends FolderState {}

class UpdateFolderError extends FolderState {
  final Failure message;
  const UpdateFolderError(this.message);
  @override
  List<Object> get props => [message];
}

class SetUsersShareWithLoading extends FolderState {}

class SetUsersShareWithSuccess extends FolderState {}

class SetUsersShareWithError extends FolderState {
  final Failure message;
  const SetUsersShareWithError(this.message);

  @override
  List<Object> get props => [message];
}

class GetAvailableUsersForShareLoading extends FolderState {}

class GetAvailableUsersForShareSuccess extends FolderState {
  final List<ShareWithmodel> users;
  const GetAvailableUsersForShareSuccess(this.users);
  @override
  List<Object> get props => [users];
}

class GetAvailableUsersForShareError extends FolderState {
  final Failure message;
  const GetAvailableUsersForShareError(this.message);
  @override
  List<Object> get props => [message];
}
