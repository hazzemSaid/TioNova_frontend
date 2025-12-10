import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/profile/data/datasource/remote_data_source_profile.dart';
import 'package:tionova/features/profile/data/models/profile_model.dart';
import 'package:tionova/features/profile/domain/repo/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final remoteDataSourceProfile remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<ServerFailure, Profile>> fetchProfile() async {
    try {
      final result = await remoteDataSource.fetchUserProfile();
      return result.fold((failure) => Left(failure), (response) {
        try {
          final profileJson = response.data['data'] as Map<String, dynamic>;
          final profile = Profile.fromJson(profileJson);
          return Right(profile);
        } catch (e) {
          return Left(
            ServerFailure('Failed to parse profile: ${e.toString()}'),
          );
        }
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await remoteDataSource.updateUserProfile(profileData);

      if (response.statusCode != 200) {
        throw ServerFailure('Failed to update profile');
      }
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
