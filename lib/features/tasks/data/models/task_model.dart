import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

/// Modelo de datos para Task
/// Maneja la serialización/deserialización JSON
@freezed
class TaskModel with _$TaskModel {
  const TaskModel._();

  const factory TaskModel({
    required String id,
    required String title,
    String? description,
    required bool completed,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _TaskModel;

  /// Crea un TaskModel desde JSON
  /// Maneja el mapeo de _id (MongoDB) a id
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final modifiedJson = Map<String, dynamic>.from(json);
    if (modifiedJson.containsKey('_id')) {
      modifiedJson['id'] = modifiedJson['_id'];
      modifiedJson.remove('_id');
    }
    return _$TaskModelFromJson(modifiedJson);
  }

  /// Convierte a entidad de dominio
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      completed: completed,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea un TaskModel desde una entidad
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      completed: task.completed,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }
}

/// DTO para crear una tarea
@freezed
class CreateTaskDto with _$CreateTaskDto {
  const factory CreateTaskDto({
    required String title,
    String? description,
  }) = _CreateTaskDto;

  factory CreateTaskDto.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskDtoFromJson(json);
}

/// DTO para actualizar una tarea
@freezed
class UpdateTaskDto with _$UpdateTaskDto {
  const factory UpdateTaskDto({
    bool? completed,
  }) = _UpdateTaskDto;

  factory UpdateTaskDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateTaskDtoFromJson(json);
}
