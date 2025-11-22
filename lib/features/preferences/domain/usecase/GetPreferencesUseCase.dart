import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/preferences/data/models/PreferencesModel.dart';
import 'package:tionova/features/preferences/domain/repo/PreferencesRepository.dart';

class GetPreferencesUseCase {
  final PreferencesRepository repository;
  GetPreferencesUseCase({required this.repository});
  Future<Either<Failure, PreferencesModel>> call() {
    return repository.getPreferences();
  }
}
