import '../../domain/entities/task.dart';
import '../models/task_model.dart';
import '../services/task_api_service.dart';

/// Repositorio de tareas
/// Actúa como intermediario entre la capa de presentación y la capa de datos
class TaskRepository {
  final TaskApiService _apiService;

  TaskRepository({TaskApiService? apiService})
      : _apiService = apiService ?? TaskApiService();

  /// Obtiene todas las tareas
  Future<List<Task>> getTasks({bool? completed}) async {
    try {
      final taskModels = await _apiService.getTasks(completed: completed);
      return taskModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Error al cargar las tareas: $e');
    }
  }

  /// Crea una nueva tarea
  Future<Task> createTask({
    required String title,
    String? description,
  }) async {
    try {
      final dto = CreateTaskDto(
        title: title,
        description: description,
      );

      final taskModel = await _apiService.createTask(dto);
      return taskModel.toEntity();
    } catch (e) {
      throw Exception('Error al crear la tarea: $e');
    }
  }

  /// Actualiza el estado de completado de una tarea
  Future<Task> toggleTaskCompletion(String id, bool completed) async {
    try {
      final dto = UpdateTaskDto(completed: completed);
      final taskModel = await _apiService.updateTask(id, dto);
      return taskModel.toEntity();
    } catch (e) {
      throw Exception('Error al actualizar la tarea: $e');
    }
  }

  /// Elimina una tarea
  Future<void> deleteTask(String id) async {
    try {
      await _apiService.deleteTask(id);
    } catch (e) {
      throw Exception('Error al eliminar la tarea: $e');
    }
  }
}
