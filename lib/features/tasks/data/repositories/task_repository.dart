import 'package:dio/dio.dart';
import '../../domain/entities/task.dart';
import '../datasources/task_local_datasource.dart';
import '../models/task_model.dart';
import '../services/task_api_service.dart';

/// Repositorio de tareas con soporte Offline
class TaskRepository {
  final TaskApiService _apiService;
  final TaskLocalDataSource _localDataSource;

  TaskRepository({
    TaskApiService? apiService,
    TaskLocalDataSource? localDataSource,
  })  : _apiService = apiService ?? TaskApiService(),
        _localDataSource = localDataSource ?? TaskLocalDataSource();

  /// Obtiene tareas (Intenta API, si falla usa Cache)
  Future<({List<Task> tasks, bool hasMore})> getTasks({
    bool? completed,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // 1. Intentar obtener de API
      final response = await _apiService.getTasks(
        completed: completed,
        page: page,
        limit: limit,
      );

      final tasks = response.data.map((model) => model.toEntity()).toList();
      
      // 2. Si es la primera página y no hay filtro, actualizar el Caché completo
      if (page == 1 && completed == null) {
        await _localDataSource.cacheTasks(tasks);
      }

      final totalPages = (response.total / limit).ceil();
      final hasMore = page < totalPages;

      return (tasks: tasks, hasMore: hasMore);
    } catch (e) {
      // 3. Fallback a Caché
      print('🌐 Error de red, usando caché local: $e');
      final localTasks = await _localDataSource.getCachedTasks();
      
      final filtered = localTasks.where((t) {
        if (completed != null) return t.completed == completed;
        return true;
      }).toList();

      return (tasks: filtered, hasMore: false);
    }
  }

  /// Crea tarea (Intenta API, si falla guarda en cola Offline)
  Future<Task> createTask({
    required String title,
    String? description,
  }) async {
    try {
      final dto = CreateTaskDto(title: title, description: description);
      final taskModel = await _apiService.createTask(dto);
      
      syncPendingActions();

      return taskModel.toEntity();
    } catch (e) {
      if (_isNetworkError(e)) {
        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        final offlineTask = Task(
          id: tempId,
          title: title,
          description: description ?? '',
          completed: false,
          createdAt: DateTime.now(),
        );
        
        await _localDataSource.addPendingAction(PendingAction(
          type: ActionType.create,
          payload: {'title': title, 'description': description, 'tempId': tempId},
        ));

        final currentCache = await _localDataSource.getCachedTasks();
        await _localDataSource.cacheTasks([offlineTask, ...currentCache]);

        return offlineTask;
      }
      rethrow;
    }
  }

  /// Actualiza datos de la tarea (título, descripción)
  Future<Task> updateTaskData(String id, {String? title, String? description}) async {
    try {
      final dto = UpdateTaskDto(title: title, description: description);
      // Asumimos que la API usa el mismo endpoint PATCH para todo
      final taskModel = await _apiService.updateTask(id, dto);
      
      syncPendingActions();

      return taskModel.toEntity();
    } catch (e) {
      if (_isNetworkError(e)) {
         await _localDataSource.addPendingAction(PendingAction(
          type: ActionType.update, // Usamos la misma acción update
          payload: {'id': id, 'title': title, 'description': description},
        ));
        
        // Actualizar caché local optimísticamente
        final currentCache = await _localDataSource.getCachedTasks();
        final index = currentCache.indexWhere((t) => t.id == id);
        if (index != -1) {
          final updatedTask = currentCache[index].copyWith(
            title: title ?? currentCache[index].title,
            description: description ?? currentCache[index].description,
          );
          currentCache[index] = updatedTask;
          await _localDataSource.cacheTasks(currentCache);
          return updatedTask;
        }
      }
      rethrow;
    }
  }

  Future<Task> toggleTaskCompletion(String id, bool completed) async {
    try {
      final dto = UpdateTaskDto(completed: completed);
      final taskModel = await _apiService.updateTask(id, dto);
      
      syncPendingActions();

      return taskModel.toEntity();
    } catch (e) {
      if (_isNetworkError(e)) {
        await _localDataSource.addPendingAction(PendingAction(
          type: ActionType.update,
          payload: {'id': id, 'completed': completed},
        ));
        
        final currentCache = await _localDataSource.getCachedTasks();
        final index = currentCache.indexWhere((t) => t.id == id);
        if (index != -1) {
          final updatedTask = currentCache[index].copyWith(completed: completed);
          currentCache[index] = updatedTask;
          await _localDataSource.cacheTasks(currentCache);
          return updatedTask;
        }
      }
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _apiService.deleteTask(id);
      syncPendingActions();
    } catch (e) {
      if (_isNetworkError(e)) {
         await _localDataSource.addPendingAction(PendingAction(
          type: ActionType.delete,
          payload: {'id': id},
        ));
        
        final currentCache = await _localDataSource.getCachedTasks();
        currentCache.removeWhere((t) => t.id == id);
        await _localDataSource.cacheTasks(currentCache);
        return;
      }
      rethrow;
    }
  }

  /// Sincroniza las acciones pendientes
  Future<void> syncPendingActions() async {
    final pendingActions = await _localDataSource.getPendingActions();
    if (pendingActions.isEmpty) return;

    print('🔄 [Repo] Intentando sincronizar ${pendingActions.length} acciones...');

    for (var action in pendingActions) {
      try {
        switch (action.type) {
          case ActionType.create:
            await _apiService.createTask(CreateTaskDto(
              title: action.payload['title'],
              description: action.payload['description'],
            ));
            break;
            
          case ActionType.update:
            // Combinar posible payload de completed y de title/desc
            // Hive store: payload = { 'id': ..., 'completed': ... } OR { 'id': ..., 'title': ... }
            await _apiService.updateTask(
              action.payload['id'],
              UpdateTaskDto(
                completed: action.payload['completed'],
                title: action.payload['title'],
                description: action.payload['description'],
              ),
            );
            break;

          case ActionType.delete:
            await _apiService.deleteTask(action.payload['id']);
            break;
        }
        
        if (action.key != null) {
          await _localDataSource.removePendingAction(action.key!);
        }
      } catch (e) {
        print('❌ Error sincronizando acción individual: $e');
      }
    }
  }
  
  bool _isNetworkError(Object error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        return true;
      }
      if (error.type == DioExceptionType.unknown && error.response == null) {
         return true; 
      }
      final errorStr = error.error?.toString() ?? '';
      final messageStr = error.message ?? '';
      return errorStr.contains('SocketException') || 
             errorStr.contains('XMLHttpRequest') ||
             messageStr.contains('XMLHttpRequest') ||
             messageStr.contains('connection error');
    }
    return false;
  }
}
