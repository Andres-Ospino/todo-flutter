import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task.dart';

part 'tasks_state.freezed.dart';

/// Estado de las tareas
/// Representa el estado de la lista de tareas en la aplicación
@freezed
class TasksState with _$TasksState {
  const factory TasksState.initial() = _Initial;
  const factory TasksState.loading() = _Loading;
  const factory TasksState.loaded(List<Task> tasks) = _Loaded;
  const factory TasksState.error(String message) = _Error;
}

/// Filtro de tareas
enum TaskFilter {
  all,
  pending,
  completed;

  String get label {
    switch (this) {
      case TaskFilter.all:
        return 'Todas';
      case TaskFilter.pending:
        return 'Pendientes';
      case TaskFilter.completed:
        return 'Completadas';
    }
  }
}
