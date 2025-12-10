import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/profile/domain/repo/profile_repository.dart';
import 'package:tionova/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;

  ProfileCubit({required this.repository}) : super(const ProfileInitial());

  /// Fetch profile data from the repository
  Future<void> fetchProfile() async {
    emit(const ProfileLoading());

    try {
      final result = await repository.fetchProfile();
      result.fold(
        (failure) => emit(ProfileError(failure.errMessage)),
        (profile) => emit(ProfileLoaded(profile)),
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// Update profile with optional image file
  Future<void> updateProfile(
    Map<String, dynamic> profileData, {
    File? imageFile,
  }) async {
    try {
      // If image file is provided, add it to the form data
      if (imageFile != null) {
        profileData['profilePicture'] = imageFile;
      }

      await repository.updateProfile(profileData);

      // Don't automatically fetch profile after update
      // This prevents widget deactivation issues during navigation
      // The screen that initiated the update will handle UI updates
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  /// Retry fetching profile (convenience method for error retry)
  Future<void> retry() async {
    await fetchProfile();
  }

  /// Refresh profile data
  Future<void> refresh() async {
    await fetchProfile();
  }
}
