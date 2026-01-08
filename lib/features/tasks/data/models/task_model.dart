// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

Object? _readId(Map json, String key) {
  return json['id'] ?? json['_id'];
}

/// Modelo de datos para Task
@freezed
class TaskModel with _$TaskModel {
  const TaskModel._();

  const factory TaskModel({
    @JsonKey(readValue: _readId) required String id,
    @Default('') String title, // Default to empty string if null
    String? description,
    @Default(false) bool completed, // Default to false if null
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

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
    String? title,
    String? description,
    bool? completed,
  }) = _UpdateTaskDto;

  factory UpdateTaskDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateTaskDtoFromJson(json);
}

/// Respuesta paginada
class PaginatedTasksResponse {
  final List<TaskModel> data;
  final int total;
  final int page;
  final int limit;

  PaginatedTasksResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PaginatedTasksResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedTasksResponse(
      data: (json['data'] as List)
          .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
    );
  }
}
