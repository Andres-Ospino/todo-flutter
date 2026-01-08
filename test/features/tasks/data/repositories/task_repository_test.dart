import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_flutter/features/tasks/data/repositories/task_repository.dart';
import 'package:todo_flutter/features/tasks/data/services/task_api_service.dart';
import 'package:todo_flutter/features/tasks/domain/entities/task.dart';
import 'package:todo_flutter/features/tasks/data/models/task_model.dart'; // Correct import

class MockTaskApiService extends Mock implements TaskApiService {}
class FakeCreateTaskDto extends Fake implements CreateTaskDto {}

void main() {
  late TaskRepository repository;
  late MockTaskApiService mockApiService;

  setUpAll(() {
    registerFallbackValue(FakeCreateTaskDto());
  });

  setUp(() {
    mockApiService = MockTaskApiService();
    repository = TaskRepository(apiService: mockApiService);
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
      expect(result.tasks.length, 1);
      expect(result.tasks.first.id, tTaskModel.id);
      expect(result.hasMore, false);
    });

    test('should return hasMore=true when total > page * limit', () async {
      // Arrange - Total 15, limit 10, page 1. So 1 * 10 < 15. hasMore should be true.
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

     test('should throw exception when API call fails', () async {
      // Arrange
      when(() => mockApiService.getTasks(page: any(named: 'page'), limit: any(named: 'limit')))
          .thenThrow(Exception('API Error'));

      // Act & Assert
      expect(() => repository.getTasks(page: 1, limit: 10), throwsException);
    });
  });

  group('createTask', () {
    final tCreateDto = CreateTaskDto(title: 'New Task');
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
      // verify(() => mockApiService.createTask(any())).called(1); // Use any() to avoid equality issues if Fake is used
      expect(result, isA<Task>());
      expect(result.title, 'New Task');
    });
  });
}
