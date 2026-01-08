import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/task_model.dart';

/// Servicio de API para tareas
class TaskApiService {
  final Dio _dio;

  TaskApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: ApiConfig.connectTimeout,
                receiveTimeout: ApiConfig.receiveTimeout,
                sendTimeout: ApiConfig.sendTimeout,
                headers: ApiConfig.defaultHeaders,
              ),
            ) {
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
    );
  }

  /// Obtiene todas las tareas con paginación
  Future<PaginatedTasksResponse> getTasks({
    bool? completed,
    int page = 1,
    int limit = AppConstants.tasksPerPage,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (completed != null) {
      queryParameters['completed'] = completed;
    }

    final response = await _dio.get(
      ApiConfig.tasksEndpoint,
      queryParameters: queryParameters,
    );

    return PaginatedTasksResponse.fromJson(response.data);
  }

  /// Crea una nueva tarea
  Future<TaskModel> createTask(CreateTaskDto dto) async {
    final response = await _dio.post(
      ApiConfig.tasksEndpoint,
      data: dto.toJson(),
    );

    return TaskModel.fromJson(response.data);
  }

  /// Actualiza una tarea
  Future<TaskModel> updateTask(String id, UpdateTaskDto dto) async {
    final response = await _dio.patch(
      '${ApiConfig.tasksEndpoint}/$id',
      data: dto.toJson(),
    );

    return TaskModel.fromJson(response.data);
  }

  /// Elimina una tarea
  Future<void> deleteTask(String id) async {
    await _dio.delete('${ApiConfig.tasksEndpoint}/$id');
  }
}
