import 'package:tionova/features/profile/data/models/profile_model.dart';

abstract class ProfileRepository {
  Future<Profile> fetchProfile();
}
