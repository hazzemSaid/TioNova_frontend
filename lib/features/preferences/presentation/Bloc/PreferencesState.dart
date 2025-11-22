import 'package:tionova/features/preferences/data/models/PreferencesModel.dart';

abstract class PreferencesState {}
/*
PreferencesInitial: Initial state
PreferencesLoading: Loading state (for both GET and PATCH)
PreferencesLoaded: Successfully loaded preferences
PreferencesUpdated: Successfully updated preferences
PreferencesError: Error state with failure message*/

class PreferencesInitial extends PreferencesState {}

class PreferencesLoading extends PreferencesState {}

class PreferencesLoaded extends PreferencesState {
  final PreferencesModel preferences;
  PreferencesLoaded({required this.preferences});
}

class PreferencesUpdated extends PreferencesState {
  final PreferencesModel preferences;
  PreferencesUpdated({required this.preferences});
}

class PreferencesError extends PreferencesState {
  final String message;
  PreferencesError({required this.message});
}
