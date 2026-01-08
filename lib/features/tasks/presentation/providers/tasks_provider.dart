import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/entities/task.dart';
import 'tasks_state.dart';

/// Provider del repositorio de tareas
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

/// Provider del filtro actual
final taskFilterProvider = StateProvider<TaskFilter>((ref) {
  return TaskFilter.all;
});

/// Notifier para manejar el estado de las tareas
class TasksNotifier extends StateNotifier<TasksState> {
  final TaskRepository _repository;

  TasksNotifier(this._repository) : super(const TasksState.initial());

  /// Carga todas las tareas
  Future<void> loadTasks() async {
    state = const TasksState.loading();

    try {
      final tasks = await _repository.getTasks();
      state = TasksState.loaded(tasks);
    } catch (e) {
      state = TasksState.error(e.toString());
    }
  }

  /// Crea una nueva tarea
  Future<void> createTask({
    required String title,
    String? description,
  }) async {
    try {
      // Crear la tarea en el backend
      final newTask = await _repository.createTask(
        title: title,
        description: description,
      );

      // Actualizar el estado con la nueva tarea
      state.whenOrNull(
        loaded: (tasks) {
          state = TasksState.loaded([newTask, ...tasks]);
        },
      );

      // Si no estábamos en estado loaded o hubo error previo, recargar todas
      state.maybeWhen(
        loaded: (_) {},
        orElse: () => loadTasks(),
      );
    } catch (e) {
      state = TasksState.error(e.toString());
    }
  }

  /// Alterna el estado de completado de una tarea
  Future<void> toggleTaskCompletion(String id, bool currentStatus) async {
    // Optimistic update: actualizar UI inmediatamente
    final List<Task> previousTasks = [];
    state.whenOrNull(
      loaded: (tasks) {
        previousTasks.addAll(tasks);
        final updatedTasks = tasks.map((task) {
          if (task.id == id) {
            return task.copyWith(completed: !currentStatus);
          }
          return task;
        }).toList();
        state = TasksState.loaded(updatedTasks);
      },
    );

    try {
      // Actualizar en el backend
      await _repository.toggleTaskCompletion(id, !currentStatus);
    } catch (e) {
      // Si falla, revertir al estado anterior
      if (previousTasks.isNotEmpty) {
        state = TasksState.loaded(previousTasks);
      }
      state = TasksState.error(e.toString());
    }
  }

  /// Elimina una tarea
  Future<void> deleteTask(String id) async {
    // Optimistic update: eliminar de la UI inmediatamente
    final List<Task> previousTasks = [];
    state.whenOrNull(
      loaded: (tasks) {
        previousTasks.addAll(tasks);
        final updatedTasks = tasks.where((task) => task.id != id).toList();
        state = TasksState.loaded(updatedTasks);
      },
    );

    try {
      // Eliminar en el backend
      await _repository.deleteTask(id);
    } catch (e) {
      // Si falla, revertir al estado anterior
      if (previousTasks.isNotEmpty) {
        state = TasksState.loaded(previousTasks);
      }
      state = TasksState.error(e.toString());
    }
  }

  /// Filtra las tareas según el filtro actual
  List<Task> getFilteredTasks(TaskFilter filter) {
    return state.whenOrNull(
          loaded: (tasks) {
            switch (filter) {
              case TaskFilter.all:
                return tasks;
              case TaskFilter.pending:
                return tasks.where((task) => !task.completed).toList();
              case TaskFilter.completed:
                return tasks.where((task) => task.completed).toList();
            }
          },
        ) ??
        [];
  }
}

/// Provider del notifier de tareas
final tasksNotifierProvider =
    StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TasksNotifier(repository);
});

/// Provider de tareas filtradas
/// Este provider combina el estado de tareas con el filtro actual
final filteredTasksProvider = Provider<List<Task>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final notifier = ref.read(tasksNotifierProvider.notifier);

  return notifier.getFilteredTasks(filter);
});

/// Provider para contar tareas por estado
final tasksCountProvider = Provider<({int total, int pending, int completed})>(
  (ref) {
    final tasksState = ref.watch(tasksNotifierProvider);

    return tasksState.whenOrNull(
          loaded: (tasks) {
            final pending = tasks.where((t) => !t.completed).length;
            final completed = tasks.where((t) => t.completed).length;
            return (total: tasks.length, pending: pending, completed: completed);
          },
        ) ??
        (total: 0, pending: 0, completed: 0);
  },
);
