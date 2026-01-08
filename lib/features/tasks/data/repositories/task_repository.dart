import '../../domain/entities/task.dart';
import '../models/task_model.dart';
import '../services/task_api_service.dart';

/// Repositorio de tareas
class TaskRepository {
  final TaskApiService _apiService;

  TaskRepository({TaskApiService? apiService})
      : _apiService = apiService ?? TaskApiService();

  /// Obtiene tareas paginadas
  /// Retorna una tupla con la lista de tareas y si hay más páginas
  Future<({List<Task> tasks, bool hasMore})> getTasks({
    bool? completed,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.getTasks(
        completed: completed,
        page: page,
        limit: limit,
      );

      final tasks = response.data.map((model) => model.toEntity()).toList();
      
      // Calculamos si hay más páginas basado en el total recibido
      final totalPages = (response.total / limit).ceil();
      final hasMore = page < totalPages;

      return (tasks: tasks, hasMore: hasMore);
    } catch (e) {
      throw Exception('Error al cargar las tareas: $e');
    }
  }

  Future<Task> createTask({
    required String title,
    String? description,
  }) async {
    try {
      final dto = CreateTaskDto(title: title, description: description);
      final taskModel = await _apiService.createTask(dto);
      return taskModel.toEntity();
    } catch (e) {
      throw Exception('Error al crear la tarea: $e');
    }
  }

  Future<Task> toggleTaskCompletion(String id, bool completed) async {
    try {
      final dto = UpdateTaskDto(completed: completed);
      final taskModel = await _apiService.updateTask(id, dto);
      return taskModel.toEntity();
    } catch (e) {
      throw Exception('Error al actualizar la tarea: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _apiService.deleteTask(id);
    } catch (e) {
      throw Exception('Error al eliminar la tarea: $e');
    }
  }
}
