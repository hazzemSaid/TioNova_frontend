# GitHub Copilot Instructions for TioNova

## Project Overview
TioNova is a Flutter-based educational platform featuring real-time challenges, quizzes, folders, and user authentication. The application uses Firebase for real-time features and follows Clean Architecture principles with BLoC state management.

## Tech Stack
- **Framework**: Flutter SDK ^3.9.2
- **State Management**: flutter_bloc ^8.1.3, Provider ^6.1.1
- **Navigation**: go_router ^16.2.1
- **Backend Integration**: Firebase (Core, Database, Realtime DB)
- **Local Storage**: Hive ^2.2.3, flutter_secure_storage ^9.2.4
- **HTTP Clients**: Dio ^5.9.0, http ^1.2.0
- **Authentication**: Google Sign-In ^6.3.0
- **Additional**: PDF viewer, Audio recording, Image picker, QR code generation

## Architecture Guidelines

### Project Structure
Follow this strict folder organization:
```
lib/
├── core/
│   ├── API/           # API clients and endpoints
│   ├── errors/        # Error handling and exceptions
│   ├── get_it/        # Dependency injection setup
│   ├── hive/          # Hive database configuration
│   ├── models/        # Core shared models
│   ├── router/        # GoRouter configuration
│   ├── services/      # Core services (download, cache, etc.)
│   ├── theme/         # App theme configuration
│   ├── utils/         # Utility functions
│   └── widgets/       # Reusable widgets
├── features/
│   ├── auth/          # Authentication feature
│   ├── challenges/    # Real-time challenges
│   ├── folder/        # Folder and chapter management
│   ├── home/          # Home screen
│   ├── profile/       # User profile
│   ├── quiz/          # Quiz functionality
│   ├── start/         # Onboarding and splash
│   └── theme/         # Theme switcher
└── main.dart
```

### Feature Module Structure
Each feature follows Clean Architecture:
```
feature_name/
├── data/
│   ├── datasources/   # Remote and local data sources
│   ├── models/        # Data models with fromJson/toJson
│   └── repositories/  # Repository implementations
├── domain/
│   ├── entities/      # Business entities
│   ├── repositories/  # Repository interfaces
│   └── usecases/      # Business logic use cases
└── presentation/
    ├── bloc/          # BLoC/Cubit state management
    │   ├── feature_cubit.dart
    │   └── feature_state.dart
    └── view/
        ├── screens/   # Full-page screens
        └── widgets/   # Feature-specific widgets
```

## Code Style & Conventions

### Naming Conventions
- **Files**: Use snake_case (e.g., `live_question_screen.dart`)
- **Classes**: Use PascalCase (e.g., `LiveQuestionScreen`)
- **Variables/Functions**: Use camelCase (e.g., `challengeCode`, `getUserData()`)
- **Constants**: Use lowerCamelCase with `const` (e.g., `const maxAttempts = 3`)
- **Private members**: Prefix with underscore (e.g., `_questionsRef`, `_loadData()`)

### BLoC/Cubit Patterns
```dart
// Always extend Cubit for simple state management
class FeatureCubit extends Cubit<FeatureState> {
  FeatureCubit() : super(FeatureInitial());
  
  Future<void> performAction() async {
    emit(FeatureLoading());
    try {
      // Business logic
      emit(FeatureSuccess(data));
    } catch (e) {
      emit(FeatureError(e.toString()));
    }
  }
}

// States should be immutable with Equatable
abstract class FeatureState extends Equatable {
  @override
  List<Object?> get props => [];
}
```

### Widget Structure
```dart
// Prefer StatelessWidget when possible
class MyWidget extends StatelessWidget {
  final String requiredParam;
  final int? optionalParam;
  
  const MyWidget({
    super.key,
    required this.requiredParam,
    this.optionalParam,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(); // Implementation
  }
}

// Use StatefulWidget for animations and lifecycle
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});
  
  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  @override
  void dispose() {
    // Always clean up resources
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### Firebase Real-time Database
```dart
// Pattern for Firebase listeners
DatabaseReference? _dataRef;
StreamSubscription<DatabaseEvent>? _dataSubscription;

void _setupListener() {
  _dataRef = FirebaseDatabase.instance.ref('path/to/data');
  _dataSubscription = _dataRef!.onValue.listen((event) {
    if (event.snapshot.exists) {
      final data = event.snapshot.value;
      // Process data
    }
  });
}

@override
void dispose() {
  _dataSubscription?.cancel();
  super.dispose();
}
```

### Navigation with GoRouter
```dart
// Navigate to route
context.go('/route-name');
context.push('/route-name');

// Navigate with parameters
context.go('/quiz/${quizId}', extra: quizData);

// Pop
context.pop();
```

## Best Practices

### Error Handling
- Always use try-catch for async operations
- Emit error states in Cubits
- Show user-friendly error messages using SnackBar
- Log errors for debugging: `print('Error: $e')`

### State Management
- Use BlocProvider at appropriate levels (not always at root)
- Use BlocBuilder for UI updates
- Use BlocListener for side effects (navigation, dialogs)
- Use BlocConsumer when you need both

### Performance
- Use `const` constructors wherever possible
- Implement `Keys` for list items
- Dispose controllers and subscriptions in `dispose()`
- Use `ListView.builder` for long lists
- Cache network images and data using Hive

### Firebase Integration
- Initialize Firebase in main.dart before runApp()
- Always check `Firebase.apps.length` before initializing
- Cancel all StreamSubscriptions in dispose()
- Use DatabaseReference for real-time listeners
- Handle null values from Firebase snapshots

### Dependency Injection
- Register services in `core/get_it/services_locator.dart`
- Use GetIt for service location: `getIt<ServiceName>()`
- Prefer singleton registration for services

## Code Generation

### Models with Hive
```dart
import 'package:hive/hive.dart';

part 'model_name.g.dart';

@HiveType(typeId: 0)
class ModelName extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  ModelName({required this.id, required this.name});
  
  factory ModelName.fromJson(Map<String, dynamic> json) => ModelName(
    id: json['id'] as String,
    name: json['name'] as String,
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}
```

### API Models
```dart
class ApiModel {
  final String id;
  final String name;
  
  ApiModel({required this.id, required this.name});
  
  factory ApiModel.fromJson(Map<String, dynamic> json) => ApiModel(
    id: json['id'] as String,
    name: json['name'] as String,
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}
```

## Common Patterns

### BlocBuilder Pattern
```dart
BlocBuilder<FeatureCubit, FeatureState>(
  builder: (context, state) {
    if (state is FeatureLoading) {
      return CircularProgressIndicator();
    } else if (state is FeatureSuccess) {
      return SuccessWidget(data: state.data);
    } else if (state is FeatureError) {
      return ErrorWidget(message: state.message);
    }
    return Container();
  },
)
```

### Provider Access
```dart
// Read once
final cubit = context.read<FeatureCubit>();

// Watch for changes
final state = context.watch<FeatureCubit>().state;

// BLoC access
final cubit = BlocProvider.of<FeatureCubit>(context);
```

### Async/Await
```dart
Future<void> loadData() async {
  try {
    final response = await apiService.getData();
    if (response.statusCode == 200) {
      // Success
    } else {
      // Handle error
    }
  } catch (e) {
    print('Error loading data: $e');
    rethrow;
  }
}
```

## UI/UX Guidelines

### Theme Usage
```dart
// Access theme
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;
final textTheme = theme.textTheme;

// Use theme colors
color: colorScheme.primary,
backgroundColor: colorScheme.surface,
```

### Responsive Design
```dart
final screenWidth = MediaQuery.of(context).size.width;
final screenHeight = MediaQuery.of(context).size.height;

// Use constraints
Container(
  width: screenWidth * 0.8,
  constraints: BoxConstraints(maxWidth: 600),
)
```

### Animations
```dart
// Use AnimationController with TickerProviderStateMixin
class _MyState extends State<MyWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## Testing Guidelines
- Place tests in `test/` directory
- Name test files with `_test.dart` suffix
- Mock dependencies using Mockito or test doubles
- Test BLoCs/Cubits independently
- Write widget tests for UI components

## Security
- Never commit sensitive data (API keys, secrets)
- Use `flutter_secure_storage` for sensitive data
- Validate user input
- Implement proper Firebase security rules
- Use environment variables for configuration

## Comments & Documentation
- Write clear, concise comments for complex logic
- Document public APIs with dartdoc comments (`///`)
- Explain "why" not "what" in comments
- Keep comments up-to-date with code changes

## When Generating Code
1. **Always** follow the feature folder structure
2. **Always** use BLoC/Cubit for state management
3. **Always** implement proper error handling
4. **Always** dispose of resources (controllers, subscriptions, streams)
5. **Always** use const constructors when possible
6. **Prefer** composition over inheritance
7. **Prefer** immutable state with Equatable
8. **Avoid** business logic in widgets
9. **Avoid** direct Firebase calls in UI (use Cubits)
10. **Ensure** null safety and type safety

## Firebase Realtime Database Structure
```
challenges/
  ├── {challengeCode}/
      ├── name: string
      ├── status: 'waiting' | 'active' | 'completed'
      ├── currentIndex: number
      ├── currentStartTime: timestamp
      ├── questions: Array<Question>
      ├── participants: Map<userId, ParticipantData>
      ├── leaderboard: Array<LeaderboardEntry>
      └── answers: Map<questionIndex, Map<userId, Answer>>
```

## Commands Reference
```bash
# Run the app
flutter run

# Build APK
flutter build apk --release

# Generate code (for Hive models)
flutter pub run build_runner build --delete-conflicting-outputs

# Clean and get dependencies
flutter clean && flutter pub get

# Run tests
flutter test

# Check for outdated packages
flutter pub outdated
```

## Import Order
Follow this order for imports:
1. Dart SDK imports
2. Flutter SDK imports
3. External package imports (alphabetically)
4. Internal package imports (alphabetically)
5. Relative imports

```dart
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:tionova/core/models/user_model.dart';
import 'package:tionova/features/auth/presentation/bloc/auth_cubit.dart';
```

## Key Features to Remember
1. **Challenges**: Real-time multiplayer quiz challenges with Firebase
2. **Quiz**: Individual quiz system with history and review
3. **Folders**: Chapter and PDF management with summaries
4. **Auth**: Email/password and Google Sign-In authentication
5. **Profile**: User profile with avatar and statistics
6. **Theme**: Dark/light theme switching

## Performance Optimization
- Use `RepaintBoundary` for complex widgets
- Implement pagination for long lists
- Cache API responses with Hive
- Use `compute` for heavy computations
- Optimize images (compress, cache)
- Lazy load data when possible

---

**Remember**: Always prioritize code quality, maintainability, and user experience. When in doubt, follow Flutter and Dart best practices and keep the code clean and testable.
