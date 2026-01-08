# To-Do Flutter App - Frontend

Flutter frontend for the To-Do application with clean architecture and Riverpod state management.

## 🚀 Tech Stack

- **Flutter** - Cross-platform mobile framework
- **Riverpod** - Modern state management
- **Dio** - HTTP client for API communication
- **Freezed** - Immutable data models
- **JSON Serializable** - JSON serialization
- **Material Design 3** - Modern UI design system

## 📋 Features

- ✅ Clean Architecture (Domain/Data/Presentation layers)
- ✅ Riverpod state management with optimistic updates
- ✅ Infinite Scroll Pagination
- ✅ Pull-to-refresh functionality
- ✅ Task filtering (All/Pending/Completed)
- ✅ Create tasks with validation
- ✅ Toggle task completion status
- ✅ Delete tasks with confirmation
- ✅ Swipe-to-delete gesture
- ✅ Loading states
- ✅ Error handling with retry
- ✅ Empty states
- ✅ Material Design 3 with dark mode
- ✅ Responsive UI

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── config/
│   │   └── api_config.dart          # API configuration
│   ├── constants/
│   │   └── app_constants.dart       # App-wide constants
│   └── theme/
│       └── app_theme.dart           # Material Design theme
├── features/
│   └── tasks/
│       ├── data/
│       │   ├── models/
│       │   │   └── task_model.dart  # Data models with JSON
│       │   ├── repositories/
│       │   │   └── task_repository.dart
│       │   └── services/
│       │       └── task_api_service.dart
│       ├── domain/
│       │   └── entities/
│       │       └── task.dart        # Business entity
│       └── presentation/
│           ├── providers/
│           │   └── tasks_provider.dart # Riverpod state
│           ├── screens/
│           │   └── tasks_screen.dart   # Main screen
│           └── widgets/
│               ├── task_item.dart
│               ├── create_task_dialog.dart
│               └── ...
├── shared/
│   └── widgets/
│       ├── loading_indicator.dart
│       ├── error_display.dart
│       ├── empty_state.dart
└── main.dart                         # App entry point
```

## 📦 Installation

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- iOS Simulator / Android Emulator / Physical Device

### Setup

```bash
# Navigate to flutter directory
cd todo-flutter

# Install dependencies
flutter pub get

# Run code generation (Freezed & JSON serialization)
dart run build_runner build --delete-conflicting-outputs
```

## 🚀 Running the Application

### Prerequisites

Make sure the backend API is running. See [../todo-nest/README.md](../todo-nest/README.md) for backend setup.

### Run on Device/Emulator

```bash
# Default (localhost)
flutter run

# Custom API URL
flutter run --dart-define=API_URL=http://10.0.2.2:3000  # Android emulator
flutter run --dart-define=API_URL=http://localhost:3000  # iOS simulator
flutter run --dart-define=API_URL=http://192.168.1.100:3000  # Physical device
```

### Platform-Specific Notes

**iOS Simulator:**
- Use `http://localhost:3000`

**Android Emulator:**
- Use `http://10.0.2.2:3000` (10.0.2.2 maps to localhost on host machine)

**Physical Device:**
- Use your computer's local IP address (e.g., `http://192.168.1.100:3000`)
- Ensure device is on the same network as your backend server

## 🏛️ Architecture

### Clean Architecture Layers

#### Domain Layer
- **Entities**: Pure business objects (`Task`)
- No dependencies on other layers

#### Data Layer
- **Models**: Data transfer objects with JSON serialization
- **Repositories**: Abstract data sources
- **Services**: API communication with Dio

#### Presentation Layer
- **Providers**: Riverpod state management
- **Screens**: Full-page widgets
- **Widgets**: Reusable UI components

### State Management

Using **Riverpod** with `StateNotifier`:

```dart
// Provider
final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TasksNotifier(repository);
});

// Usage in widgets
final state = ref.watch(tasksProvider);
ref.read(tasksProvider.notifier).createTask(...);
```

## 🎨 UI Features

- **Material Design 3** with dynamic color schemes
- **Dark mode** support (follows system preference)
- **Pull-to-refresh** to reload tasks
- **Swipe-to-delete** with confirmation dialog
- **Filter menu** to show All/Pending/Completed tasks
- **Empty states** with helpful messages
- **Error handling** with retry buttons
- **Loading indicators**

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 🛠️ Development

### Code Generation

When you modify `@freezed` or JSON serializable classes:

```bash
# Watch mode (auto-regenerate on file changes)
dart run build_runner watch

# One-time build
dart run build_runner build --delete-conflicting-outputs
```

### Linting

```bash
# Analyze code
flutter analyze

# Format code
dart format .
```

## 🌐 API Configuration

Default API URL: `http://localhost:3000`

To change, edit [`lib/core/config/api_config.dart`](file:///Users/smartinfo/Documents/GitHub/todo-nest-mongo-flutter/todo-flutter/lib/core/config/api_config.dart) or use `--dart-define` flag.

## 📱 Platform Support

- ✅ iOS
- ✅ Android
- ✅ Web
- ✅ macOS
- ✅ Windows
- ✅ Linux

## 🐛 Troubleshooting

### Cannot connect to API

1. Ensure backend is running on port 3000
2. Check correct API URL for your platform
3. For Android emulator, use `10.0.2.2` instead of `localhost`

### Code generation errors

```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## 📄 License

MIT License

## 👨‍💻 Author

Developed as a technical test demonstrating semi-senior level Flutter development with clean architecture and Riverpod state management.
