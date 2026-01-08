import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task.dart';

part 'tasks_state.freezed.dart';

/// Enum para los filtros de tareas
enum TaskFilter {
  all('Todas'),
  pending('Pendientes'),
  completed('Completadas');

  final String label;
  const TaskFilter(this.label);
}

/// Estado de la lista de tareas
@freezed
class TasksState with _$TasksState {
  const factory TasksState.initial() = _Initial;
  const factory TasksState.loading() = _Loading;
  const factory TasksState.loaded(
    List<Task> tasks, {
    @Default(true) bool hasMore,
    @Default(false) bool isLoadingMore,
  }) = _Loaded;
  const factory TasksState.error(String message) = _Error;
}
