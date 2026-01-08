import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/entities/task.dart';
import 'tasks_state.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final taskFilterProvider = StateProvider<TaskFilter>((ref) {
  return TaskFilter.all;
});

class TasksNotifier extends StateNotifier<TasksState> {
  final TaskRepository _repository;
  
  // Estado interno para paginación
  int _currentPage = 1;

  TasksNotifier(this._repository) : super(const TasksState.initial());

  /// Carga inicial de tareas (reinicia pagina)
  Future<void> loadTasks({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }

    final isLoading = state.maybeMap(loading: (_) => true, orElse: () => false);
    final isLoaded = state.maybeMap(loaded: (_) => true, orElse: () => false);

    if (!refresh && (isLoading || isLoaded)) {
       return;
    }

    state = const TasksState.loading();

    try {
      final result = await _repository.getTasks(
        page: 1,
        limit: AppConstants.tasksPerPage,
      );
      
      _currentPage = 1;
      state = TasksState.loaded(
        result.tasks, 
        hasMore: result.hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      state = TasksState.error(e.toString());
    }
  }

  /// Carga la siguiente página de tareas
  Future<void> loadMoreTasks() async {
    final currentState = state.mapOrNull(loaded: (s) => s);
    if (currentState == null) return;
    
    if (!currentState.hasMore || currentState.isLoadingMore) return;
    
    // Poner isLoadingMore en true
    state = currentState.copyWith(isLoadingMore: true);

    try {
      final nextPage = _currentPage + 1;
      final result = await _repository.getTasks(
        page: nextPage,
        limit: AppConstants.tasksPerPage,
      );

      _currentPage = nextPage;
      
      // Concatenar tareas
      state = TasksState.loaded(
        [...currentState.tasks, ...result.tasks],
        hasMore: result.hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      // Si falla, revertir isLoadingMore pero mantener lista
      state = currentState.copyWith(isLoadingMore: false);
      print('Error loading more tasks: $e'); 
    }
  }

  Future<void> createTask({required String title, String? description}) async {
    try {
      final newTask = await _repository.createTask(title: title, description: description);
      
      state.whenOrNull(loaded: (tasks, hasMore, isLoadingMore) {
        state = TasksState.loaded(
          [newTask, ...tasks],
          hasMore: hasMore,
          isLoadingMore: isLoadingMore,
        );
      });

      final isLoaded = state.maybeMap(loaded: (_) => true, orElse: () => false);
      if (!isLoaded) {
        loadTasks(refresh: true);
      }
    } catch (e) {
      state = TasksState.error(e.toString());
    }
  }

  Future<void> toggleTaskCompletion(String id, bool currentStatus) async {
    final currentState = state.mapOrNull(loaded: (s) => s);
    if (currentState == null) return;

    final previousTasks = currentState.tasks;
    final updatedTasks = previousTasks.map((task) {
      if (task.id == id) return task.copyWith(completed: !currentStatus);
      return task;
    }).toList();
    
    state = currentState.copyWith(tasks: updatedTasks);

    try {
      await _repository.toggleTaskCompletion(id, !currentStatus);
    } catch (e) {
      state = currentState.copyWith(tasks: previousTasks); // Revert
      state = TasksState.error(e.toString());
    }
  }

  Future<void> deleteTask(String id) async {
    print('🗑️ [Notifier] Attempting to delete task: "$id"');
    final currentState = state.mapOrNull(loaded: (s) => s);
    if (currentState == null) {
      print('⚠️ [Notifier] Cannot delete: State is not loaded');
      return;
    }

    final previousTasks = currentState.tasks;
    print('📊 [Notifier] Previous tasks count: ${previousTasks.length}');
    
    // Debug IDs
    // previousTasks.forEach((t) => print(' - Task: ${t.title} (${t.id})'));

    final updatedTasks = previousTasks.where((task) => task.id.toString() != id.toString()).toList();
    print('📉 [Notifier] Updated tasks count: ${updatedTasks.length}');
    
    state = currentState.copyWith(tasks: updatedTasks);

    try {
      await _repository.deleteTask(id);
    } catch (e) {
       print('❌ [Notifier] Delete failed, reverting. Error: $e');
       state = currentState.copyWith(tasks: previousTasks); // Revert
       state = TasksState.error(e.toString());
    }
  }

  Future<void> updateTask(String id, {String? title, String? description}) async {
      try {
        // En este paso, el repositorio debería tener un método update general.
        // Si no, lo usamos solo con lo que tenemos o lo extendemos.
        // Asumiendo que updateTask del repo soporta update de titulo/desc.
        // Si no, tendremos que ajustarlo.
        
        // Optimistic update
        final currentState = state.mapOrNull(loaded: (s) => s);
         if (currentState != null) {
            final updatedList = currentState.tasks.map((t) {
              if (t.id == id) {
                return t.copyWith(
                  title: title ?? t.title,
                  description: description ?? t.description
                );
              }
              return t;
            }).toList();
             state = currentState.copyWith(tasks: updatedList);
         }

         // Llamada API (necesitamos asegurar que el repo soporte esto)
          await _repository.updateTaskData(id, title: title, description: description);

      } catch (e) {
        state = TasksState.error(e.toString());
         // Revertir si fuese necesario, pero por brevedad omitimos logica compleja de revert aqui
         loadTasks(refresh: true);
      }
  }

  List<Task> getFilteredTasks(TaskFilter filter) {
    return state.maybeWhen(
      loaded: (tasks, _, __) {
        switch (filter) {
          case TaskFilter.all:
            return tasks;
          case TaskFilter.pending:
            return tasks.where((task) => !task.completed).toList();
          case TaskFilter.completed:
            return tasks.where((task) => task.completed).toList();
        }
      },
      orElse: () => [],
    );
  }
}

final tasksNotifierProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return TasksNotifier(repository);
});

final filteredTasksProvider = Provider<List<Task>>((ref) {
  final filter = ref.watch(taskFilterProvider);
  final notifier = ref.read(tasksNotifierProvider.notifier);
  // Subscribe to state changes
  ref.watch(tasksNotifierProvider); 
  return notifier.getFilteredTasks(filter);
});

final tasksCountProvider = Provider<({int total, int pending, int completed})>((ref) {
  final tasksState = ref.watch(tasksNotifierProvider);
  
  return tasksState.maybeWhen(
    loaded: (tasks, _, __) {
        final pending = tasks.where((t) => !t.completed).length;
        final completed = tasks.where((t) => t.completed).length;
        return (total: tasks.length, pending: pending, completed: completed);
    },
    orElse: () => (total: 0, pending: 0, completed: 0),
  );
});
