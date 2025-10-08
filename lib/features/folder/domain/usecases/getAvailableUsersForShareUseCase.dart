import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/folder/data/models/ShareWithmodel.dart';
import 'package:tionova/features/folder/domain/repo/IFolderRepository.dart';

class GetAvailableUsersForShareUseCase {
  final IFolderRepository repository;

  GetAvailableUsersForShareUseCase(this.repository);

  Future<Either<Failure, List<ShareWithmodel>>> call({
    required String query,
    required String token,
  }) {
    return repository.getAvailableUsersForShare(query: query, token: token);
  }
}
