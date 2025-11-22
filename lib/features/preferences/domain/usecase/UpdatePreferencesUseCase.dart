import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/preferences/data/models/PreferencesModel.dart';
import 'package:tionova/features/preferences/domain/repo/PreferencesRepository.dart';

class UpdatePreferencesUseCase {
  final PreferencesRepository repository;
  UpdatePreferencesUseCase({required this.repository});
  Future<Either<Failure, PreferencesModel>> call({
    required Map<String, dynamic> data,
  }) {
    return repository.updatePreferences(data);
  }
}
