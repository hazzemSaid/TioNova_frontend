import 'package:bloc/bloc.dart';
import 'package:tionova/core/utils/safe_emit.dart';
import 'package:tionova/features/preferences/domain/usecase/GetPreferencesUseCase.dart';
import 'package:tionova/features/preferences/domain/usecase/UpdatePreferencesUseCase.dart';
import 'package:tionova/features/preferences/presentation/Bloc/PreferencesState.dart';

class PreferencesCubit extends Cubit<PreferencesState> {
  PreferencesCubit({
    required this.getPreferencesUseCase,
    required this.updatePreferencesUseCase,
  }) : super(PreferencesInitial());
  final GetPreferencesUseCase getPreferencesUseCase;
  final UpdatePreferencesUseCase updatePreferencesUseCase;

  bool _hasFetched = false;

  /// Check if user is new (has no preferences)
  /// Returns true if 404 error (no preferences found)
  Future<bool> checkIfNewUser() async {
    // If already loaded, user is not new
    if (state is PreferencesLoaded) return false;
    final result = await getPreferencesUseCase.call();
    return result.fold(
      (failure) {
        // If 404 status code, user is new
        if (failure.statusCode == '404') {
          return true;
        }
        // For other errors, assume not new (to avoid forcing preferences)
        return false;
      },
      (preferences) {
        // User has preferences, not new, emit loaded state
        _hasFetched = true;
        safeEmit(PreferencesLoaded(preferences: preferences));
        return false;
      },
    );
  }

  void getPreferences() async {
    // Prevent duplicate requests if already fetched or loading
    if (_hasFetched ||
        state is PreferencesLoading ||
        state is PreferencesLoaded)
      return;
    safeEmit(PreferencesLoading());
    final result = await getPreferencesUseCase.call();
    result.fold(
      (failure) => safeEmit(PreferencesError(message: failure.errMessage)),
      (preferences) {
        _hasFetched = true;
        safeEmit(PreferencesLoaded(preferences: preferences));
      },
    );
  }

  void updatePreferences(Map<String, dynamic> data) async {
    print('🔵 PreferencesCubit: updatePreferences called');
    safeEmit(PreferencesLoading());
    final result = await updatePreferencesUseCase.call(data: data);
    print('🔵 PreferencesCubit: Got result from useCase');
    result.fold(
      (failure) {
        print('❌ PreferencesCubit: Error - ${failure.errMessage}');
        safeEmit(PreferencesError(message: failure.errMessage));
      },
      (preferences) {
        print('✅ PreferencesCubit: Success - Emitting PreferencesUpdated');
        print('✅ Preferences data: ${preferences.toJson()}');
        safeEmit(PreferencesUpdated(preferences: preferences));
        print('✅ PreferencesCubit: State after emit: $state');
      },
    );
  }
}
