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
      // (Para simplificar este demo, cacheamos lo que llega si es página 1)
      if (page == 1 && completed == null) {
        await _localDataSource.cacheTasks(tasks);
      }

      final totalPages = (response.total / limit).ceil();
      final hasMore = page < totalPages;

      return (tasks: tasks, hasMore: hasMore);
    } catch (e) {
      // 3. Fallback a Caché si falla la API (Solo soportamos paginación local básica o todo)
      // Para este MVP, devolvemos todo lo del caché
      print('🌐 Error de red, usando caché local: $e');
      final localTasks = await _localDataSource.getCachedTasks();
      
      // Simular filtrado local
      final filtered = localTasks.where((t) {
        if (completed != null) return t.completed == completed;
        return true;
      }).toList();

      return (tasks: filtered, hasMore: false); // Asumimos no more pages locally for now
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
      return taskModel.toEntity();
    } catch (e) {
      // Si el error es de conexión (DioExceptionType)
      if (_isNetworkError(e)) {
        // Generar ID temporal y guardar acción pendiente
        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        final offlineTask = Task(
          id: tempId,
          title: title,
          description: description ?? '',
          completed: false,
          createdAt: DateTime.now(),
        );
        
        // Guardar acción pendiente
        await _localDataSource.addPendingAction(PendingAction(
          type: ActionType.create,
          payload: {'title': title, 'description': description, 'tempId': tempId},
        ));

        // Tambien guardar en caché para que se vea inmediatamente (Optimistic)
        // (Esto requiere leer el caché actual, agregar y guardar)
        final currentCache = await _localDataSource.getCachedTasks();
        await _localDataSource.cacheTasks([offlineTask, ...currentCache]);

        return offlineTask;
      }
      rethrow;
    }
  }

  Future<Task> toggleTaskCompletion(String id, bool completed) async {
    try {
      final dto = UpdateTaskDto(completed: completed);
      final taskModel = await _apiService.updateTask(id, dto);
      return taskModel.toEntity();
    } catch (e) {
      if (_isNetworkError(e)) {
         // Guardar acción pendiente
        await _localDataSource.addPendingAction(PendingAction(
          type: ActionType.update,
          payload: {'id': id, 'completed': completed},
        ));
        
        // Actualizar caché local
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
    } catch (e) {
      if (_isNetworkError(e)) {
         await _localDataSource.addPendingAction(PendingAction(
          type: ActionType.delete,
          payload: {'id': id},
        ));
        
        // Actualizar caché
        final currentCache = await _localDataSource.getCachedTasks();
        currentCache.removeWhere((t) => t.id == id);
        await _localDataSource.cacheTasks(currentCache);
        return;
      }
      rethrow;
    }
  }
  
  bool _isNetworkError(Object error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
             error.type == DioExceptionType.receiveTimeout ||
             error.type == DioExceptionType.sendTimeout ||
             error.type == DioExceptionType.connectionError ||
             error.error.toString().contains('SocketException'); // Fallback
    }
    return false;
  }
}
