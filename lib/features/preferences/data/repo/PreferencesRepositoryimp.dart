import 'package:either_dart/src/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/preferences/data/datasources/preferencesreomtedatasource.dart';
import 'package:tionova/features/preferences/data/models/PreferencesModel.dart';
import 'package:tionova/features/preferences/domain/repo/PreferencesRepository.dart';

class PreferencesRepositoryimp implements PreferencesRepository {
  final PreferencesRemoteDataSourceImpl preferencesRemoteDataSourceImpl;
  PreferencesRepositoryimp({required this.preferencesRemoteDataSourceImpl});
  @override
  Future<Either<Failure, PreferencesModel>> getPreferences() {
    return preferencesRemoteDataSourceImpl.getPreferences();
  }

  @override
  Future<Either<Failure, PreferencesModel>> updatePreferences(
    Map<String, dynamic> preferences,
  ) {
    return preferencesRemoteDataSourceImpl.updatePreferences(preferences);
  }
}
