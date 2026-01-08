import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_flutter/core/constants/app_constants.dart';
import 'package:todo_flutter/core/theme/app_theme.dart';
import 'package:todo_flutter/features/tasks/data/repositories/task_repository.dart';
import 'package:todo_flutter/features/tasks/domain/entities/task.dart';
import 'package:todo_flutter/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:todo_flutter/features/tasks/presentation/screens/tasks_screen.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const TasksScreen(),
      ),
    );
  }

  testWidgets('TasksScreen renders correctly', (tester) async {
    // Arrange: Mock loadTasks call which is called on init
    when(() => mockRepository.getTasks(page: 1, limit: any(named: 'limit')))
        .thenAnswer((_) async => (tasks: <Task>[], hasMore: false));

    // Act
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Allow init logic

    // Assert
    expect(find.text(AppConstants.appName), findsOneWidget); // Use constant
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
