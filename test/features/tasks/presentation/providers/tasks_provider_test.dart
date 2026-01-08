import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_flutter/features/tasks/data/repositories/task_repository.dart';
import 'package:todo_flutter/features/tasks/domain/entities/task.dart';
import 'package:todo_flutter/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:todo_flutter/features/tasks/presentation/providers/tasks_state.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  late TasksNotifier notifier;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    notifier = TasksNotifier(mockRepository);
  });

  group('TasksNotifier', () {
    final tTask = Task(
      id: '1',
      title: 'Test Task',
      description: 'Desc',
      completed: false,
      createdAt: DateTime.now(),
    );

    test('initial state should be TasksState.initial', () {
      expect(notifier.state, const TasksState.initial());
    });

    test('loadTasks should update state to loaded when successful', () async {
      // Arrange
      when(() => mockRepository.getTasks(page: 1, limit: any(named: 'limit')))
          .thenAnswer((_) async => (tasks: [tTask], hasMore: false));

      // Act
      await notifier.loadTasks();

      // Assert
      verify(() => mockRepository.getTasks(page: 1, limit: any(named: 'limit'))).called(1);
      
      expect(notifier.state.maybeMap(
        loaded: (state) => state.tasks.length == 1 && state.tasks.first == tTask,
        orElse: () => false,
      ), true);
    });

    test('loadTasks should update state to error when failure', () async {
      // Arrange
      when(() => mockRepository.getTasks(page: 1, limit: any(named: 'limit')))
          .thenThrow(Exception('Error'));

      // Act
      await notifier.loadTasks();

      // Assert
      expect(notifier.state.maybeMap(
        error: (_) => true,
        orElse: () => false,
      ), true);
    });

    test('loadMoreTasks should append tasks', () async {
      // Arrange
      // Primero cargamos estado inicial
      when(() => mockRepository.getTasks(page: 1, limit: any(named: 'limit')))
          .thenAnswer((_) async => (tasks: [tTask], hasMore: true));
      await notifier.loadTasks();

      final tTask2 = Task(id: '2', title: 'Task 2', completed: false, createdAt: DateTime.now());
      when(() => mockRepository.getTasks(page: 2, limit: any(named: 'limit')))
          .thenAnswer((_) async => (tasks: [tTask2], hasMore: false));

      // Act
      await notifier.loadMoreTasks();

      // Assert
      expect(notifier.state.maybeMap(
        loaded: (state) => state.tasks.length == 2 && !state.hasMore,
        orElse: () => false,
      ), true);
    });

    test('createTask should add task optimistically (or via reload)', () async { 
      // Arrange
      when(() => mockRepository.getTasks(page: 1, limit: any(named: 'limit')))
          .thenAnswer((_) async => (tasks: <Task>[], hasMore: false)); // Typed list
      await notifier.loadTasks(); // Set state to loaded

      final tNewTask = Task(id: 'new', title: 'New', completed: false, createdAt: DateTime.now());
      when(() => mockRepository.createTask(title: 'New', description: null))
          .thenAnswer((_) async => tNewTask);

      // Act
      await notifier.createTask(title: 'New');

      // Assert
      expect(notifier.state.maybeMap(
        loaded: (state) => state.tasks.contains(tNewTask),
        orElse: () => false,
      ), true);
    });
  });
}
