import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_flutter/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:todo_flutter/features/tasks/data/repositories/task_repository.dart';
import 'package:todo_flutter/features/tasks/data/services/task_api_service.dart';
import 'package:todo_flutter/features/tasks/domain/entities/task.dart';
import 'package:todo_flutter/features/tasks/data/models/task_model.dart';
import 'package:dio/dio.dart';

class MockTaskApiService extends Mock implements TaskApiService {}
class MockTaskLocalDataSource extends Mock implements TaskLocalDataSource {}
class FakeCreateTaskDto extends Fake implements CreateTaskDto {}
class FakePendingAction extends Fake implements PendingAction {}

void main() {
  late TaskRepository repository;
  late MockTaskApiService mockApiService;
  late MockTaskLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(FakeCreateTaskDto());
    registerFallbackValue(FakePendingAction());
  });

  setUp(() {
    mockApiService = MockTaskApiService();
    mockLocalDataSource = MockTaskLocalDataSource();
    
    // Default mocks
    when(() => mockLocalDataSource.cacheTasks(any())).thenAnswer((_) async {});
    when(() => mockLocalDataSource.getCachedTasks()).thenAnswer((_) async => []);
    when(() => mockLocalDataSource.addPendingAction(any())).thenAnswer((_) async {});
    when(() => mockLocalDataSource.getPendingActions()).thenAnswer((_) async => <PendingAction>[]);

    repository = TaskRepository(
      apiService: mockApiService,
      localDataSource: mockLocalDataSource,
    );
  });

  group('getTasks', () {
    final tTaskModel = TaskModel(
      id: '1',
      title: 'Test Task',
      completed: false,
      createdAt: DateTime.now(),
    );
    
    test('should return list of tasks and hasMore=false when total <= limit', () async {
      // Arrange
      when(() => mockApiService.getTasks(page: 1, limit: 10))
          .thenAnswer((_) async => PaginatedTasksResponse(
            data: [tTaskModel], 
            total: 1, 
            page: 1, 
            limit: 10
          ));

      // Act
      final result = await repository.getTasks(page: 1, limit: 10);

      // Assert
      verify(() => mockApiService.getTasks(page: 1, limit: 10)).called(1);
      verify(() => mockLocalDataSource.cacheTasks(any())).called(1); // Should cache on page 1
      expect(result.tasks.length, 1);
      expect(result.tasks.first.id, tTaskModel.id);
      expect(result.hasMore, false);
    });

    test('should return hasMore=true when total > page * limit', () async {
      // Arrange
      final response = PaginatedTasksResponse(
        data: [tTaskModel],
        total: 15,
        page: 1,
        limit: 10,
      );
      
      when(() => mockApiService.getTasks(page: 1, limit: 10))
          .thenAnswer((_) async => response);

      // Act
      final result = await repository.getTasks(page: 1, limit: 10);

      // Assert
      expect(result.hasMore, true);
    });

     test('should return local cache when API call fails', () async {
      // Arrange
      when(() => mockApiService.getTasks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenThrow(Exception('API Error'));
      
      when(() => mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => [tTaskModel.toEntity()]);

      // Act
      final result = await repository.getTasks(page: 1, limit: 10);
      
      // Assert
      verify(() => mockLocalDataSource.getCachedTasks()).called(1);
      expect(result.tasks.length, 1);
      expect(result.tasks.first.title, 'Test Task');
    });
  });

  group('createTask', () {
    final tTaskModel = TaskModel(
      id: '1',
      title: 'New Task',
      completed: false,
      createdAt: DateTime.now(),
    );

    test('should return created task entity', () async {
      // Arrange
      when(() => mockApiService.createTask(any())).thenAnswer((_) async => tTaskModel);

      // Act
      final result = await repository.createTask(title: 'New Task');

      // Assert
      expect(result, isA<Task>());
      expect(result.title, 'New Task');
    });
    
    test('should cache pending action and return offline task on Network Error', () async {
      // Arrange
      when(() => mockApiService.createTask(any())).thenThrow(
        DioException(requestOptions: RequestOptions(), type: DioExceptionType.connectionError)
      );
      when(() => mockLocalDataSource.getCachedTasks()).thenAnswer((_) async => []);

      // Act
      final result = await repository.createTask(title: 'Offline Task');

      // Assert
      verify(() => mockLocalDataSource.addPendingAction(any())).called(1);
      expect(result.title, 'Offline Task');
      expect(result.id, startsWith('temp_'));
    });
  });
}
