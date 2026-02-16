<!-- Minimal README for maintainers and contributors -->
# TioNova

Lightweight cross-platform learning app — Flutter frontend.

## Quick start

Requirements

- Flutter >= 3.38.0
- Dart >= 3.9.0

Setup

```bash
git clone https://github.com/hazzemSaid/TioNova_frontend.git
cd TioNova_frontend
flutter pub get
```

Add Firebase config for mobile builds:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Run (examples)

```bash
# Debug
flutter run

# Web
flutter run -d chrome

# Build web
flutter build web --release
```

## Project notes

- Main entry: `lib/main.dart` (uses `AppInitializer`).
- Routing: `go_router`. State: `flutter_bloc`/Cubit.
- Core code: `lib/core/`; features: `lib/features/`.
- Dependencies: see `pubspec.yaml`.

## Useful commands

```bash
flutter analyze
flutter test
flutter pub run build_runner build --delete-conflicting-outputs
```

## License

MIT — see `LICENSE`.

Live demo: https://tionova-c566b.web.app/ · Backend: https://github.com/hazzemSaid/TioNova_backend
# TioNova

A minimal, focused README for the TioNova Flutter app.

## Quick start

Requirements

- Flutter >= 3.38.0
- Dart >= 3.9.0

Clone and install

```bash
git clone https://github.com/hazzemSaid/TioNova_frontend.git
cd TioNova_frontend
flutter pub get
```

Firebase

- Place `google-services.json` in `android/app/` and `GoogleService-Info.plist` in `ios/Runner/` when building for mobile.

Run

```bash
# Debug
flutter run

# Web
flutter run -d chrome

# Web production build
flutter build web --release
```

## What you need to know

- Core code lives in `lib/` (see `lib/features/` and `lib/core/`).
- Routing uses `go_router`; state management uses `flutter_bloc`.
- Backend features (AI summaries, quizzes) are powered by the companion backend; realtime features use Firebase Realtime Database.
- See `pubspec.yaml` for full dependency versions.

## Useful commands

```bash
flutter analyze
flutter test
flutter pub run build_runner build --delete-conflicting-outputs
```

## License

MIT — see `LICENSE`.

---

Live demo: https://tionova-c566b.web.app/ · Backend: https://github.com/hazzemSaid/TioNova_backend


**State Machine:**
```dart
ChallengeInitial → ChallengeLoading → ChallengeCreated (host)
                                    → ChallengeJoined (participant)
                 → ChallengeWaiting → ChallengeInProgress → ChallengeCompleted
```

---

### ⚙️ User Preferences (`features/preferences/`)

6-step onboarding flow for personalized learning experience.

| Step | Configuration |
|------|--------------|
| **Step 1** | Daily Chapter Goal (1-10 chapters/day) |
| **Step 2** | Preferred Study Times (Early Morning, Morning, Afternoon, Evening, Night) |
| **Step 3** | Daily Time Commitment (15-180 minutes) |
| **Step 4** | Study Schedule (1-7 days/week) |
| **Step 5** | Learning Goals (Exams, New Topics, Review, Grades, Practice, Career) |
| **Step 6** | Content Difficulty (Easy, Medium, Hard, Progressive) |

**Data Structure:**
```json
{
  "studyPerDay": 2,
  "preferredStudyTimes": "evening",
  "dailyTimeCommitmentMinutes": 30,
  "daysPerWeek": 5,
  "goals": ["Prepare for Exams", "Review Materials"],
  "contentDifficulty": "medium"
}
```

---

### 👤 User Profile (`features/profile/`)

User profile management with statistics and avatar customization.

**Features:**
- Profile picture upload/update
- Learning statistics dashboard
- Streak tracking and achievements
- Account settings management

---

### 🎨 Theme System (`features/theme/`)

Dynamic theming with persistence.

**Supported Themes:**
- 🌙 **Dark Mode** - Eye-friendly dark interface
- ☀️ **Light Mode** - Clean, bright design
- 🔄 **System** - Auto-detect OS preference

**Implementation:**
- `ThemeCubit` for state management
- Persistent theme preference via Hive
- Smooth theme transitions

---

## 📸 Screenshots

<div align="center">

| Home Screen | Challenge | Quiz |
|:-----------:|:---------:|:----:|
| *AI-powered dashboard* | *Real-time multiplayer* | *Interactive quizzes* |

</div>

---

## 🛠 Tech Stack

### Frontend Framework & Language
| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | 3.9+ | Cross-platform UI framework |
| **Dart** | 3.9+ | Type-safe programming language |

### State Management & Architecture
| Package | Version | Purpose |
|---------|---------|---------|
| **flutter_bloc** | ^8.1.3 | BLoC/Cubit state management |
| **bloc** | ^8.1.4 | Core BLoC library |
| **equatable** | ^2.0.5 | Value equality for states |
| **provider** | ^6.1.1 | Dependency injection & simple state |
| **get_it** | ^8.2.0 | Service locator pattern |

### Navigation & Routing
| Package | Version | Purpose |
|---------|---------|---------|
| **go_router** | ^16.2.1 | Declarative routing |

### Backend & Firebase
| Package | Version | Purpose |
|---------|---------|---------|
| **firebase_core** | ^4.2.0 | Firebase initialization |
| **firebase_database** | ^12.0.3 | Realtime Database |
| **firebase_messaging** | ^16.0.3 | Push notifications |

### Authentication
| Package | Version | Purpose |
|---------|---------|---------|
| **google_sign_in** | ^6.3.0 | Google OAuth2 |
| **flutter_secure_storage** | ^9.2.4 | Secure token storage |

### Networking
| Package | Version | Purpose |
|---------|---------|---------|
| **dio** | ^5.9.0 | HTTP client with interceptors |
| **http** | ^1.2.0 | Basic HTTP requests |
| **pretty_dio_logger** | ^1.4.0 | Network debugging |
| **internet_connection_checker** | ^3.0.1 | Connectivity monitoring |
| **flutter_client_sse** | ^2.0.3 | Server-sent events |

### Local Storage
| Package | Version | Purpose |
|---------|---------|---------|
| **hive** | ^2.2.3 | NoSQL local database |
| **hive_flutter** | ^1.1.0 | Flutter Hive integration |
| **shared_preferences** | ^2.2.2 | Simple key-value storage |

### UI/UX Components
| Package | Version | Purpose |
|---------|---------|---------|
| **cupertino_icons** | ^1.0.8 | iOS-style icons |
| **ionicons** | ^0.2.2 | Ionicons icon pack |
| **dotted_border** | ^3.1.0 | Decorative borders |
| **lottie** | ^3.1.0 | Lottie animations |
| **shimmer** | ^3.0.0 | Loading shimmer effects |
| **skeletonizer** | ^2.1.0+1 | Skeleton loading states |

### Media & Files
| Package | Version | Purpose |
|---------|---------|---------|
| **flutter_pdfview** | ^1.3.2 | PDF viewing |
| **pdf** | ^3.10.4 | PDF generation |
| **file_picker** | ^8.0.0+1 | File selection |
| **image_picker** | ^1.0.7 | Image selection |
| **path_provider** | ^2.1.2 | File system paths |

### Audio & Multimedia
| Package | Version | Purpose |
|---------|---------|---------|
| **flutter_sound** | ^9.2.13 | Audio recording/playback |
| **audio_waveforms** | ^1.3.0 | Audio visualization |

### QR Code & Scanning
| Package | Version | Purpose |
|---------|---------|---------|
| **qr_flutter** | ^4.1.0 | QR code generation |
| **mobile_scanner** | ^5.2.3 | QR/barcode scanning |

### Utilities
| Package | Version | Purpose |
|---------|---------|---------|
| **intl** | ^0.19.0 | Internationalization |
| **permission_handler** | ^11.3.0 | Runtime permissions |
| **package_info_plus** | ^8.0.0 | App version info |
| **open_file** | ^3.5.10 | Open files externally |
| **either_dart** | ^1.0.0 | Functional error handling |

### OTA Updates
| Package | Version | Purpose |
|---------|---------|---------|
| **shorebird_code_push** | ^2.0.5 | Over-the-air updates |

### Development & Testing
| Package | Version | Purpose |
|---------|---------|---------|
| **flutter_test** | SDK | Widget & unit testing |
| **mocktail** | ^0.3.0 | Mocking for tests |
| **bloc_test** | ^9.1.7 | BLoC testing utilities |
| **build_runner** | ^2.4.7 | Code generation |
| **hive_generator** | ^2.0.1 | Hive adapter generation |
| **flutter_launcher_icons** | ^0.14.4 | App icon generation |
| **flutter_lints** | ^5.0.0 | Dart linting rules |

### AI Models (Backend)
| Model | Purpose |
|-------|---------|
| **BART-CNN** | Text summarization |
| **T5** | Question generation |
| **DistilBERT** | Chatbot responses |

---

## 🏗 Architecture

TioNova follows **Clean Architecture** principles with a feature-first organization:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PRESENTATION LAYER                                 │
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────────────────────────┐  │
│  │    Screens    │  │    Widgets    │  │        BLoC / Cubit             │  │
│  │  (StatelessW) │  │  (Reusable)   │  │  ┌─────────────────────────┐   │  │
│  └───────────────┘  └───────────────┘  │  │ State ←→ Events/Methods │   │  │
│         ↑                   ↑          │  └─────────────────────────┘   │  │
│         └───────────────────┴──────────┴────────────────────────────────┘  │
├─────────────────────────────────────────────────────────────────────────────┤
│                             DOMAIN LAYER                                     │
│  ┌───────────────┐  ┌───────────────────┐  ┌─────────────────────────────┐  │
│  │   Entities    │  │     Use Cases     │  │   Repository Interfaces     │  │
│  │ (Pure Dart)   │  │ (Business Logic)  │  │   (Abstract Classes)        │  │
│  └───────────────┘  └───────────────────┘  └─────────────────────────────┘  │
│         ↑                    ↑                          ↑                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                              DATA LAYER                                      │
│  ┌───────────────┐  ┌───────────────────┐  ┌─────────────────────────────┐  │
│  │    Models     │  │   Data Sources    │  │  Repository Implementations │  │
│  │ (JSON/Hive)   │  │ ┌───────┬───────┐ │  │  (Concrete Classes)         │  │
│  │               │  │ │Remote │ Local │ │  │                             │  │
│  └───────────────┘  │ │ (API) │(Hive) │ │  └─────────────────────────────┘  │
│                     │ └───────┴───────┘ │                                    │
│                     └───────────────────┘                                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                          EXTERNAL SERVICES                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  Firebase   │  │  REST API   │  │    Hive     │  │  Secure Storage     │ │
│  │  Realtime   │  │  (Backend)  │  │  (NoSQL)    │  │  (Tokens)           │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Data Flow Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                              User Action                                  │
│                                   │                                       │
│                                   ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐ │
│  │                          UI (Widget)                                 │ │
│  │                    context.read<Cubit>().action()                   │ │
│  └─────────────────────────────────────────────────────────────────────┘ │
│                                   │                                       │
│                                   ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐ │
│  │                         Cubit / BLoC                                 │ │
│  │               emit(Loading) → UseCase.call() → emit(Result)         │ │
│  └─────────────────────────────────────────────────────────────────────┘ │
│                                   │                                       │
│                                   ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐ │
│  │                           Use Case                                   │ │
│  │                      repository.method()                            │ │
│  └─────────────────────────────────────────────────────────────────────┘ │
│                                   │                                       │
│                                   ▼                                       │
│  ┌─────────────────────────────────────────────────────────────────────┐ │
│  │                    Repository Implementation                         │ │
│  │          Either<Failure, Success> ← dataSource.fetch()             │ │
│  └─────────────────────────────────────────────────────────────────────┘ │
│                                   │                                       │
│                    ┌──────────────┴──────────────┐                       │
│                    ▼                              ▼                       │
│  ┌─────────────────────────┐      ┌─────────────────────────────────┐   │
│  │   Remote Data Source    │      │      Local Data Source          │   │
│  │    Dio HTTP Client      │      │         Hive Box                │   │
│  └─────────────────────────┘      └─────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────┘
```

### Dependency Injection (GetIt)

```dart
// Service registration in core/get_it/
final getIt = GetIt.instance;

void setupDependencies() {
  // Data Sources
  getIt.registerLazySingleton<RemoteAuthDataSource>(() => RemoteAuthDataSourceImpl());
  getIt.registerLazySingleton<LocalAuthDataSource>(() => LocalAuthDataSourceImpl());
  
  // Repositories
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(
    remoteDataSource: getIt(),
    localDataSource: getIt(),
  ));
  
  // Use Cases
  getIt.registerFactory(() => LoginUseCase(getIt()));
  getIt.registerFactory(() => RegisterUseCase(getIt()));
  
  // Cubits
  getIt.registerFactory(() => AuthCubit(
    loginUseCase: getIt(),
    registerUseCase: getIt(),
  ));
}
```

### Key Architectural Decisions

| Decision | Rationale |
|----------|-----------|
| **Feature-First Structure** | Each feature is self-contained, improving maintainability and team collaboration |
| **Clean Architecture** | Separation of concerns, testability, and independence from frameworks |
| **BLoC/Cubit Pattern** | Predictable state management with clear state transitions |
| **Repository Pattern** | Abstract data sources, enabling easy mocking and source switching |
| **Either for Error Handling** | Functional approach to handle success/failure without exceptions |
| **GetIt for DI** | Simple service locator with lazy initialization support |

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** >= 3.9.0
- **Dart SDK** >= 3.9.0
- **Android Studio** / **VS Code**
- **Git**

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/hazzemSaid/TioNova_frontend.git
   cd TioNova_frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   # Follow FIREBASE_HOSTING_SETUP.md for detailed instructions
   # Ensure google-services.json (Android) and GoogleService-Info.plist (iOS) are in place
   ```

4. **Run the app**
   ```bash
   # Debug mode
   flutter run
   
   # Release mode
   flutter run --release
   
   # Web
   flutter run -d chrome
   ```

### Quick Commands

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run in debug mode |
| `flutter build apk` | Build Android APK |
| `flutter build web` | Build for web |
| `flutter test` | Run tests |
| `flutter analyze` | Analyze code |

---

## 📂 Project Structure

```
lib/
├── core/                          # Core functionality
│   ├── blocobserve/               # BLoC observer for debugging
│   ├── errors/                    # Error handling & exceptions
│   ├── get_it/                    # Dependency injection setup
│   ├── hive/                      # Local database configuration
│   ├── models/                    # Shared data models
│   ├── router/                    # GoRouter configuration
│   ├── services/                  # Core services (API, cache, etc.)
│   ├── theme/                     # App theming
│   ├── utils/                     # Utility functions & extensions
│   └── widgets/                   # Reusable UI components
│
├── features/                      # Feature modules (Clean Architecture)
│   │
│   ├── auth/                      # 🔐 Authentication
│   │   ├── data/
│   │   │   ├── AuthDataSource/    # Remote & local data sources
│   │   │   ├── models/            # UserModel with Hive adapters
│   │   │   ├── repo/              # AuthRepoImpl
│   │   │   └── services/          # TokenStorage, AuthService
│   │   ├── domain/
│   │   │   ├── repo/              # AuthRepo interface
│   │   │   └── usecases/          # Login, Register, GoogleAuth, etc.
│   │   └── presentation/
│   │       ├── bloc/              # AuthCubit & AuthState
│   │       └── view/              # Screens & widgets
│   │
│   ├── challenges/                # 🏆 Real-Time Challenges
│   │   ├── data/
│   │   │   ├── datasource/        # Firebase real-time data source
│   │   │   ├── model/             # ChallengeCode model
│   │   │   └── repo/              # LiveChallengeImplRepo
│   │   ├── domain/
│   │   │   ├── entities/          # IChallengeCode entity
│   │   │   ├── repo/              # LiveChallengeRepo interface
│   │   │   └── usecase/           # Create, Join, Start, Submit, etc.
│   │   └── presentation/
│   │       ├── bloc/              # ChallengeCubit (590+ lines)
│   │       ├── services/          # Polling, Sound, Vibration, Timer
│   │       └── view/              # Challenge screens & widgets
│   │
│   ├── folder/                    # 📂 Content Management
│   │   ├── data/
│   │   │   ├── datasources/       # Remote folder data source
│   │   │   ├── models/            # Folder, Chapter, Summary, Mindmap
│   │   │   ├── repoimp/           # Repository implementations
│   │   │   └── services/          # File handling services
│   │   ├── domain/
│   │   │   ├── repo/              # IChapterRepository, IFolderRepository
│   │   │   └── usecases/          # 21 use cases (CRUD, AI features)
│   │   └── presentation/
│   │       ├── bloc/              # Folder & Chapter Cubits
│   │       └── view/              # PDF viewer, folder browser
│   │
│   ├── quiz/                      # 📝 Quiz System
│   │   ├── data/
│   │   │   ├── datasources/       # Quiz API data source
│   │   │   ├── models/            # QuizModel, PracticeModeQuizModel
│   │   │   └── repo/              # QuizRepoImpl
│   │   ├── domain/
│   │   │   ├── repo/              # QuizRepo interface
│   │   │   └── usecases/          # CreateQuiz, GetHistory, PracticeMode
│   │   └── presentation/
│   │       ├── bloc/              # QuizCubit with multiple modes
│   │       ├── view/              # Quiz screens
│   │       └── widgets/           # Question cards, progress bars
│   │
│   ├── preferences/               # ⚙️ User Preferences (6-step onboarding)
│   │   ├── data/                  # Preferences data layer
│   │   ├── domain/                # Preferences domain layer
│   │   └── presentation/          # Multi-step preference screens
│   │
│   ├── profile/                   # 👤 User Profile
│   │   ├── data/                  # Profile data & models
│   │   ├── domain/                # ProfileRepository interface
│   │   └── presentation/          # Profile screens & cubit
│   │
│   ├── home/                      # 🏠 Home Dashboard
│   │   ├── data/                  # Dashboard data
│   │   ├── domain/                # Home use cases
│   │   └── presentation/          # Home screen with provider
│   │
│   ├── start/                     # 🚀 Splash & Onboarding
│   │   ├── data/                  # Startup data
│   │   └── presentation/          # Splash screen, onboarding flow
│   │
│   └── theme/                     # 🎨 Theme Management
│       └── presentation/
│           ├── bloc/              # ThemeCubit
│           └── widgets/           # Theme toggle widgets
│
├── utils/                         # Global utilities
├── firebase_options.dart          # Firebase configuration
└── main.dart                      # App entry point
```

### Feature Module Pattern

Each feature follows a consistent Clean Architecture pattern:

```
feature_name/
├── data/                          # Data Layer
│   ├── datasources/               # API calls, local storage
│   │   ├── remote_datasource.dart # Network requests
│   │   └── local_datasource.dart  # Hive, SharedPreferences
│   ├── models/                    # DTOs with serialization
│   │   └── feature_model.dart     # fromJson(), toJson()
│   └── repo/                      # Repository implementations
│       └── feature_repo_impl.dart # Implements domain interface
│
├── domain/                        # Domain Layer (Business Logic)
│   ├── entities/                  # Core business objects
│   ├── repo/                      # Repository interfaces
│   │   └── feature_repo.dart      # Abstract class
│   └── usecases/                  # Single-responsibility use cases
│       └── feature_usecase.dart   # Execute business logic
│
└── presentation/                  # Presentation Layer
    ├── bloc/                      # State management
    │   ├── feature_cubit.dart     # Cubit with use cases
    │   └── feature_state.dart     # Equatable states
    └── view/
        ├── screens/               # Full-page widgets
        └── widgets/               # Reusable components
```
│
├── utils/                         # Global utilities
├── firebase_options.dart          # Firebase configuration
└── main.dart                      # App entry point
```

---

## ⚙️ Configuration

### Environment Setup

Create environment-specific configuration as needed:

```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const String apiBaseUrl = 'YOUR_API_URL';
  static const String firebaseProjectId = 'YOUR_PROJECT_ID';
}
```

### Firebase Configuration

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable Authentication (Google Sign-In, Email/Password)
3. Enable Realtime Database
4. Download configuration files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`

See [FIREBASE_HOSTING_SETUP.md](FIREBASE_HOSTING_SETUP.md) and [GOOGLE_OAUTH_SETUP.md](GOOGLE_OAUTH_SETUP.md) for detailed instructions.

---

## 🧪 Testing

TioNova includes comprehensive test coverage:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/auth_cubit_test.dart

# Run integration tests
flutter test integration_test/
```

### Test Structure

```
test/
├── bloc/                    # BLoC tests
├── datasources/             # Data source tests
├── features/                # Feature-specific tests
├── integration/             # Integration tests
├── utils/                   # Utility tests
├── mocks.dart               # Mock definitions
└── widget_test.dart         # Widget tests
```

---

## 🚢 Deployment

### Web (Firebase Hosting)

```bash
# Build for web
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting
```

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS

```bash
# Build for iOS
flutter build ios --release

# Archive and upload via Xcode
```

### Over-the-Air Updates (Shorebird)

TioNova supports Shorebird for instant updates:

```bash
# Create a patch
shorebird patch android
shorebird patch ios
```

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` before committing
- Write tests for new features
- Update documentation as needed

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Team

<div align="center">

| Role | Contributor |
|------|-------------|
| **Developer** | [@hazzemSaid](https://github.com/hazzemSaid) |

</div>

---

## 🔗 Links

- 🌐 **Live Demo**: [tionova-c566b.web.app](https://tionova-c566b.web.app/)
- 📦 **Backend**: [TioNova Backend Repository](https://github.com/hazzemSaid/TioNova_backend)
- 📖 **Flutter Docs**: [flutter.dev](https://flutter.dev)
- 🔥 **Firebase**: [firebase.google.com](https://firebase.google.com)

---

<div align="center">

**Made with ❤️ and Flutter**

⭐ Star this repository if you find it helpful!

</div>