import 'package:flutter_test/flutter_test.dart';
import 'package:todo_flutter/features/tasks/domain/entities/task.dart';

void main() {
  group('Task Entity', () {
    final now = DateTime(2024, 1, 10);
    
    final testTask = Task(
      id: '1',
      title: 'Test Task',
      description: 'Test Description',
      completed: false,
      createdAt: now,
      updatedAt: now,
    );

    test('should create a task with all properties', () {
      expect(testTask.id, '1');
      expect(testTask.title, 'Test Task');
      expect(testTask.description, 'Test Description');
      expect(testTask.completed, false);
      expect(testTask.createdAt, now);
      expect(testTask.updatedAt, now);
    });

    test('should create a task without optional fields', () {
      final task = Task(
        id: '2',
        title: 'Minimal Task',
        completed: false,
        createdAt: now,
      );

      expect(task.id, '2');
      expect(task.title, 'Minimal Task');
      expect(task.description, null);
      expect(task.updatedAt, null);
    });

    group('copyWith', () {
      test('should create a copy with modified title', () {
        final updated = testTask.copyWith(title: 'Updated Title');

        expect(updated.id, testTask.id);
        expect(updated.title, 'Updated Title');
        expect(updated.description, testTask.description);
        expect(updated.completed, testTask.completed);
      });

      test('should create a copy with modified completion status', () {
        final completed = testTask.copyWith(completed: true);

        expect(completed.id, testTask.id);
        expect(completed.title, testTask.title);
        expect(completed.completed, true);
      });

      test('should create a copy with multiple modified fields', () {
        final newUpdatedAt = DateTime(2024, 1, 15);
        final updated = testTask.copyWith(
          title: 'New Title',
          completed: true,
          updatedAt: newUpdatedAt,
        );

        expect(updated.title, 'New Title');
        expect(updated.completed, true);
        expect(updated.updatedAt, newUpdatedAt);
        expect(updated.description, testTask.description);
      });

      test('should return identical copy when no parameters provided', () {
        final copy = testTask.copyWith();

        expect(copy.id, testTask.id);
        expect(copy.title, testTask.title);
        expect(copy.description, testTask.description);
        expect(copy.completed, testTask.completed);
      });
    });

    group('equality', () {
      test('should be equal when ids match', () {
        final task1 = Task(
          id: '1',
          title: 'Task 1',
          completed: false,
          createdAt: now,
        );

        final task2 = Task(
          id: '1',
          title: 'Task 1 Different Title',
          completed: true,
          createdAt: now,
        );

        expect(task1, equals(task2));
        expect(task1.hashCode, equals(task2.hashCode));
      });

      test('should not be equal when ids differ', () {
        final task1 = Task(
          id: '1',
          title: 'Task',
          completed: false,
          createdAt: now,
        );

        final task2 = Task(
          id: '2',
          title: 'Task',
          completed: false,
          createdAt: now,
        );

        expect(task1, isNot(equals(task2)));
      });

      test('should be identical to itself', () {
        expect(testTask, equals(testTask));
      });
    });

    group('toString', () {
      test('should return formatted string representation', () {
        final str = testTask.toString();

        expect(str, contains('Task'));
        expect(str, contains('id: 1'));
        expect(str, contains('title: Test Task'));
        expect(str, contains('completed: false'));
      });
    });
  });
}
