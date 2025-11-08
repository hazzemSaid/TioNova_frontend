# GetIt Integration Instructions for Live Challenge Feature

## Step 1: Add Import Statement

Add this import at the top of `lib/core/get_it/services_locator.dart`:

```dart
import 'package:tionova/features/challenges/domain/usecase/checkAndAdvanceusecase.dart';
```

## Step 2: Register CheckAndAdvanceUseCase

Add this registration in the appropriate section (with other use cases):

```dart
// Register CheckAndAdvanceUseCase
getIt.registerLazySingleton(
  () => CheckAndAdvanceUseCase(
    liveChallengeRepo: getIt<RemoteLiveChallengeDataSource>(),
  ),
);
```

## Step 3: Update ChallengeCubit Registration

Find the existing `ChallengeCubit` registration and update it to include the new use case:

```dart
// Update ChallengeCubit registration
getIt.registerFactory(
  () => ChallengeCubit(
    createLiveChallengeUseCase: getIt<CreateLiveChallengeUseCase>(),
    joinLiveChallengeUseCase: getIt<JoinLiveChallengeUseCase>(),
    startLiveChallengeUseCase: getIt<StartLiveChallengeUseCase>(),
    submitLiveAnswerUseCase: getIt<SubmitLiveAnswerUseCase>(),
    disconnectfromlivechallengeusecase: getIt<Disconnectfromlivechallengeusecase>(),
    checkAndAdvanceUseCase: getIt<CheckAndAdvanceUseCase>(), // ADD THIS LINE
  ),
);
```

## Step 4: Verify Setup

Run the app and check for any GetIt dependency resolution errors in the console.

## Complete Example

Here's what the updated section should look like:

```dart
// ==========================================
// Live Challenge Feature Registration
// ==========================================

// Data Sources
getIt.registerLazySingleton<RemoteLiveChallengeDataSource>(
  () => RemoteLiveChallengeDataSource(dio: getIt<Dio>()),
);

// Use Cases
getIt.registerLazySingleton(
  () => CreateLiveChallengeUseCase(liveChallengeRepo: getIt()),
);

getIt.registerLazySingleton(
  () => JoinLiveChallengeUseCase(liveChallengeRepo: getIt()),
);

getIt.registerLazySingleton(
  () => StartLiveChallengeUseCase(liveChallengeRepo: getIt()),
);

getIt.registerLazySingleton(
  () => SubmitLiveAnswerUseCase(liveChallengeRepo: getIt()),
);

getIt.registerLazySingleton(
  () => Disconnectfromlivechallengeusecase(liveChallengeRepo: getIt()),
);

// NEW: CheckAndAdvance Use Case
getIt.registerLazySingleton(
  () => CheckAndAdvanceUseCase(liveChallengeRepo: getIt()),
);

// Cubit
getIt.registerFactory(
  () => ChallengeCubit(
    createLiveChallengeUseCase: getIt(),
    joinLiveChallengeUseCase: getIt(),
    startLiveChallengeUseCase: getIt(),
    submitLiveAnswerUseCase: getIt(),
    disconnectfromlivechallengeusecase: getIt(),
    checkAndAdvanceUseCase: getIt(), // NEW
  ),
);
```

## Testing After Integration

1. Run the app: `flutter run`
2. Navigate to a live challenge
3. Check console for polling messages:
   - "LiveQuestionScreen - Starting polling service"
   - "ChallengeCubit - Checking if should advance question"
4. Verify no GetIt errors appear

## Troubleshooting

**Error: "Object/factory with  type CheckAndAdvanceUseCase is not registered"**
- Make sure you added the `registerLazySingleton` for `CheckAndAdvanceUseCase`
- Ensure the import statement is present

**Error: "Missing required parameter checkAndAdvanceUseCase"**
- Make sure you updated the `ChallengeCubit` registration with the new parameter

**Error: "Type 'RemoteLiveChallengeDataSource' not found"**
- Ensure `RemoteLiveChallengeDataSource` is properly registered
- Check the import for the data source
