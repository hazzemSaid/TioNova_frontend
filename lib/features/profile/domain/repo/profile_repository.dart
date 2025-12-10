import 'package:either_dart/either.dart';
import 'package:tionova/core/errors/failure.dart';
import 'package:tionova/features/profile/data/models/profile_model.dart';

abstract class ProfileRepository {
  Future<Either<ServerFailure, Profile>> fetchProfile();

  Future<void> updateProfile(Map<String, dynamic> profileData);
}
