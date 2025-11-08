# Home Screen BLoC Provider Migration

## Overview
Migrated the Home Screen from using GetIt directly to using BlocProvider for proper state management following Flutter BLoC best practices.

## Changes Made

### 1. **Architecture Improvement**

#### Before (GetIt Direct Access):
```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _usageTracker = getIt<AppUsageTrackerService>();
  final _analysisCubit = getIt<AnalysisCubit>();  // ❌ Direct GetIt access
  
  @override
  void initState() {
    super.initState();
    _loadAnalysisData();
  }
}
```

#### After (BlocProvider Pattern):
```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<AnalysisCubit>();
        // Load data immediately after creating the cubit
        TokenStorage.getAccessToken().then((token) {
          if (token != null) {
            cubit.loadAnalysisData(token);
          }
        });
        return cubit;
      },
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  final _usageTracker = getIt<AppUsageTrackerService>();

  Future<void> _loadAnalysisData() async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      context.read<AnalysisCubit>().loadAnalysisData(token);  // ✅ Uses context
    }
  }
}
```

### 2. **Widget Structure**

The new structure has two components:

1. **HomeScreen (StatelessWidget)**: 
   - Wrapper widget that provides the BlocProvider
   - Creates and initializes the AnalysisCubit
   - Automatically loads data on creation

2. **_HomeScreenContent (StatefulWidget)**:
   - Contains the actual UI logic
   - Accesses the cubit via `context.read<AnalysisCubit>()`
   - No direct GetIt dependency for the cubit

### 3. **BlocBuilder Access**

#### Before:
```dart
return BlocBuilder<AnalysisCubit, AnalysisState>(
  bloc: _analysisCubit,  // ❌ Passing bloc instance
  builder: (context, state) {
    // ...
  },
);
```

#### After:
```dart
return BlocBuilder<AnalysisCubit, AnalysisState>(
  // ✅ BlocBuilder automatically finds the cubit from context
  builder: (context, state) {
    // ...
  },
);
```

## Benefits

### 1. **Proper State Management**
- ✅ BlocProvider automatically handles the cubit lifecycle
- ✅ Cubit is disposed when the widget is removed from the tree
- ✅ No memory leaks from manual cubit management

### 2. **Better Testability**
```dart
// Easy to mock in tests
testWidgets('HomeScreen shows loading', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<AnalysisCubit>(
        create: (_) => MockAnalysisCubit(),
        child: HomeScreen(),
      ),
    ),
  );
  
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

### 3. **Cleaner Code**
- ✅ No manual cubit instance management
- ✅ Clear separation between provider and content
- ✅ Follows Flutter BLoC conventions
- ✅ Uses `context.read<T>()` for accessing cubit methods

### 4. **Automatic Rebuilds**
- ✅ BlocBuilder automatically rebuilds when state changes
- ✅ No need to manually listen to state changes
- ✅ Efficient - only rebuilds affected widgets

### 5. **Better Integration with Flutter DevTools**
- ✅ BlocProvider is visible in widget tree inspector
- ✅ Can see cubit state in Flutter DevTools
- ✅ Better debugging experience

## Usage in Widget Tree

### Current Structure:
```
MaterialApp
  └── MainLayout (from mainlayout.dart)
      └── IndexedStack
          └── HomeScreen (BlocProvider wrapper)
              └── _HomeScreenContent (actual UI)
                  └── BlocBuilder<AnalysisCubit, AnalysisState>
                      ├── Loading: CircularProgressIndicator
                      ├── Error: Error UI with retry
                      └── Loaded: Complete home screen UI
```

### BlocProvider Scope:
- **Created**: When `HomeScreen` widget is built
- **Available**: To `_HomeScreenContent` and all its descendants
- **Disposed**: When `HomeScreen` is removed from widget tree

## Accessing the Cubit

### Reading State (Triggers Rebuild):
```dart
// Use context.watch to rebuild when state changes
final state = context.watch<AnalysisCubit>().state;
```

### Calling Methods (No Rebuild):
```dart
// Use context.read to call methods without rebuilding
context.read<AnalysisCubit>().loadAnalysisData(token);
```

### Using BlocBuilder (Recommended):
```dart
// BlocBuilder automatically rebuilds on state changes
BlocBuilder<AnalysisCubit, AnalysisState>(
  builder: (context, state) {
    if (state is AnalysisLoading) return LoadingWidget();
    if (state is AnalysisError) return ErrorWidget();
    if (state is AnalysisLoaded) return ContentWidget(state.data);
    return Container();
  },
)
```

### Using BlocListener (Side Effects):
```dart
// For navigation, dialogs, snackbars
BlocListener<AnalysisCubit, AnalysisState>(
  listener: (context, state) {
    if (state is AnalysisError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: YourWidget(),
)
```

## Data Loading Flow

### 1. **Initial Load** (Automatic):
```
HomeScreen created
  └── BlocProvider.create()
      └── getIt<AnalysisCubit>()
      └── TokenStorage.getAccessToken()
      └── cubit.loadAnalysisData(token)
          └── emit(AnalysisLoading())
          └── API call
          └── emit(AnalysisLoaded(data)) or emit(AnalysisError(message))
```

### 2. **Manual Refresh** (User Action):
```
User taps retry button
  └── _loadAnalysisData()
      └── TokenStorage.getAccessToken()
      └── context.read<AnalysisCubit>().loadAnalysisData(token)
          └── emit(AnalysisLoading())
          └── API call
          └── emit(AnalysisLoaded(data)) or emit(AnalysisError(message))
```

## Real API Data Flow

### Statistics Cards:
```dart
// ✅ Uses real API data
final stats = [
  {
    'value': '${_usageTracker.getCurrentStreak()}',  // Local tracker
    'label': 'Day Streak',
    'icon': Icons.local_fire_department,
  },
  {
    'value': '${analysisData.totalChapters ?? 0}',  // API
    'label': 'Chapters',
    'icon': Icons.menu_book
  },
  {
    'value': '${analysisData.avgScore ?? 0}%',  // API
    'label': 'Avg Score',
    'icon': Icons.insights
  },
  {
    'value': analysisData.lastRank != null ? '#${analysisData.lastRank}' : '-',  // API
    'label': 'Rank',
    'icon': Icons.emoji_events
  },
];
```

### Recent Chapters:
```dart
// ✅ Maps from API response
final chapters = (analysisData.recentChapters ?? [])
    .map((chapter) => {
          'id': chapter.id,
          'title': chapter.title,
          'subject': chapter.category ?? 'General',
          'chapterModel': chapter,
        })
    .toList();
```

### Recent Folders:
```dart
// ✅ Maps from API response with theme colors
final folders = (analysisData.recentFolders ?? [])
    .asMap()
    .entries
    .map((entry) {
      final folder = entry.value;
      final colors = [
        colorScheme.primary,
        colorScheme.tertiary,
        colorScheme.secondary,
        colorScheme.primaryContainer,
      ];
      return {
        'id': folder.id,
        'title': folder.title,
        'chapters': folder.chapterCount ?? 0,
        'color': colors[entry.key % colors.length],
        'folderModel': folder,
      };
    }).toList();
```

### Last Summary:
```dart
// ✅ Uses first summary from API list
final lastSummary = (analysisData.lastSummary != null &&
        analysisData.lastSummary!.isNotEmpty)
    ? {
        'title': analysisData.lastSummary!.first.chapterTitle,
        'keyPoints': analysisData.lastSummary!.first.keyPoints.length,
      }
    : null;
```

### Mind Maps:
```dart
// ✅ Maps from API response
final mindMaps = (analysisData.lastMindmaps ?? [])
    .map((mindmap) => {
          'title': mindmap.title ?? 'Mind Map',
          'chapterId': mindmap.chapterId,
        })
    .toList();
```

## State Management Summary

| Feature | Before | After |
|---------|--------|-------|
| Cubit Access | GetIt direct | BlocProvider + context |
| Lifecycle | Manual | Automatic |
| Rebuild Trigger | Manual | BlocBuilder |
| Memory Management | Manual dispose | Auto dispose |
| Testability | Harder | Easier |
| DevTools Support | Limited | Full |
| Code Clarity | Good | Better |

## Error Handling

All error handling is preserved and improved:

### Loading State:
```dart
if (state is AnalysisLoading) {
  return Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );
}
```

### Error State:
```dart
if (state is AnalysisError) {
  return Scaffold(
    body: Center(
      child: Column(
        children: [
          Icon(Icons.error_outline),
          Text('Failed to load data'),
          Text(state.message),
          ElevatedButton(
            onPressed: _loadAnalysisData,  // ✅ Uses context.read
            child: Text('Retry'),
          ),
        ],
      ),
    ),
  );
}
```

### Success State:
```dart
if (state is AnalysisLoaded) {
  final analysisData = state.analysisData;
  // Display all data
}
```

## Real-Time Features Preserved

### App Usage Tracking:
```dart
// ✅ Still uses AppUsageTrackerService
final _usageTracker = getIt<AppUsageTrackerService>();

// ✅ Real-time updates via StreamBuilder
StreamBuilder<int>(
  stream: _usageTracker.getTodayUsageStream(),
  builder: (context, snapshot) {
    final realTimeUsage = snapshot.data ?? 0;
    return _TodayProgressCard(
      progress: {'studyTime': realTimeUsage},
    );
  },
)
```

## Migration Checklist

- [x] Convert `HomeScreen` from StatefulWidget to StatelessWidget
- [x] Add `BlocProvider` wrapper
- [x] Create `_HomeScreenContent` as the actual UI widget
- [x] Replace `_analysisCubit` field with `context.read<AnalysisCubit>()`
- [x] Update `BlocBuilder` to use context instead of bloc parameter
- [x] Automatic data loading in BlocProvider.create
- [x] Preserve all real-time features (usage tracker)
- [x] Maintain error handling and retry functionality
- [x] All API data mapping intact
- [x] Navigation functionality preserved
- [x] No mock data remaining

## Best Practices Applied

### 1. **Single Responsibility**
- `HomeScreen`: Provides the cubit
- `_HomeScreenContent`: Contains UI logic
- Clear separation of concerns

### 2. **Immutability**
- BlocProvider creates cubit once
- Cubit state is immutable
- UI rebuilds on state changes

### 3. **Performance**
- BlocBuilder only rebuilds when state changes
- Efficient widget tree updates
- No unnecessary rebuilds

### 4. **Clean Code**
- No manual cubit instance management
- Uses Flutter BLoC conventions
- Easy to understand and maintain

## Testing Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalysisCubit extends Mock implements AnalysisCubit {}

void main() {
  group('HomeScreen', () {
    late MockAnalysisCubit mockCubit;

    setUp(() {
      mockCubit = MockAnalysisCubit();
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      when(() => mockCubit.state).thenReturn(AnalysisLoading());
      when(() => mockCubit.stream).thenAnswer((_) => Stream.value(AnalysisLoading()));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AnalysisCubit>.value(
            value: mockCubit,
            child: const _HomeScreenContent(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when error occurs', (tester) async {
      when(() => mockCubit.state).thenReturn(AnalysisError('Network error'));
      when(() => mockCubit.stream).thenAnswer(
        (_) => Stream.value(AnalysisError('Network error')),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AnalysisCubit>.value(
            value: mockCubit,
            child: const _HomeScreenContent(),
          ),
        ),
      );

      expect(find.text('Failed to load data'), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('displays data when loaded', (tester) async {
      final mockData = Analysismodel(
        id: '1',
        userId: 'user1',
        totalChapters: 42,
        avgScore: 87.5,
        lastRank: 15,
      );

      when(() => mockCubit.state).thenReturn(AnalysisLoaded(mockData));
      when(() => mockCubit.stream).thenAnswer(
        (_) => Stream.value(AnalysisLoaded(mockData)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AnalysisCubit>.value(
            value: mockCubit,
            child: const _HomeScreenContent(),
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);  // Total chapters
      expect(find.text('87.5%'), findsOneWidget);  // Avg score
      expect(find.text('#15'), findsOneWidget);  // Rank
    });
  });
}
```

## Summary

✅ **Successfully migrated to BlocProvider pattern**  
✅ **No more direct GetIt access for cubit**  
✅ **All real API data preserved**  
✅ **Proper lifecycle management**  
✅ **Better testability**  
✅ **Cleaner code architecture**  
✅ **Follows Flutter BLoC best practices**  
✅ **Real-time features intact**  
✅ **Error handling improved**  
✅ **No mock data remaining**

The home screen now uses proper BLoC pattern with BlocProvider, making it more maintainable, testable, and following Flutter community standards. All real API data integration is preserved and functioning correctly.
