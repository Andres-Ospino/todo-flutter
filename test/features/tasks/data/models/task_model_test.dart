import 'package:flutter_test/flutter_test.dart';
import 'package:todo_flutter/features/tasks/data/models/task_model.dart';
import 'package:todo_flutter/features/tasks/domain/entities/task.dart';

void main() {
  group('TaskModel', () {
    final tTaskModel = TaskModel(
      id: '1',
      title: 'Test Task',
      description: 'Test Description',
      completed: false,
      createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
    );

    test('should be a subclass of Task entity', () async {
      final entity = tTaskModel.toEntity();
      expect(entity, isA<Task>());
      expect(entity.id, tTaskModel.id);
      expect(entity.title, tTaskModel.title);
    });

    test('fromJson should return a valid model from JSON', () async {
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'title': 'Test Task',
        'description': 'Test Description',
        'completed': false,
        'createdAt': '2023-01-01T00:00:00.000Z',
      };

      final result = TaskModel.fromJson(jsonMap);

      expect(result.id, '1');
      expect(result.title, 'Test Task');
      // Comparar en UTC para evitar problemas de zona horaria
      expect(result.createdAt, DateTime.parse('2023-01-01T00:00:00.000Z'));
    });

    test('fromJson should handle _id field from MongoDB', () async {
      final Map<String, dynamic> jsonMap = {
        '_id': '1',
        'title': 'Test Task',
        'completed': false,
        'createdAt': '2023-01-01T00:00:00.000Z',
      };

      final result = TaskModel.fromJson(jsonMap);

      expect(result.id, '1'); // Should map _id to id
    });

    test('toJson should return a JSON map containing proper data', () async {
      final result = tTaskModel.toJson();
      expect(result['id'], tTaskModel.id);
      expect(result['title'], tTaskModel.title);
    });
  });
  
  group('PaginatedTasksResponse', () {
    test('fromJson should return valid response', () {
       final Map<String, dynamic> jsonMap = {
        'data': [
          {
            '_id': '1',
            'title': 'Task 1',
            'completed': false,
            'createdAt': '2023-01-01T00:00:00.000Z'
          }
        ],
        'total': 10,
        'page': 1,
        'limit': 5
      };
      
      final result = PaginatedTasksResponse.fromJson(jsonMap);
      
      expect(result.data.length, 1);
      expect(result.data.first.id, '1');
      expect(result.total, 10);
      expect(result.page, 1);
      expect(result.limit, 5);
    });
  });
}
