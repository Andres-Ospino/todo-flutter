import 'package:dio/dio.dart';
import '../../../core/config/api_config.dart';
import '../models/task_model.dart';

/// Servicio de API para tareas
/// Maneja todas las peticiones HTTP relacionadas con tareas
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
    // Interceptor para logging (útil en desarrollo)
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
    );
  }

  /// Obtiene todas las tareas con filtros opcionales
  Future<List<TaskModel>> getTasks({
    bool? completed,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (completed != null) {
        queryParameters['completed'] = completed;
      }

      final response = await _dio.get(
        ApiConfig.tasksEndpoint,
        queryParameters: queryParameters,
      );

      // El backend retorna un array de tareas
      final List<dynamic> data = response.data as List;
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Crea una nueva tarea
  Future<TaskModel> createTask(CreateTaskDto dto) async {
    try {
      final response = await _dio.post(
        ApiConfig.tasksEndpoint,
        data: dto.toJson(),
      );

      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Actualiza una tarea (toggle completed)
  Future<TaskModel> updateTask(String id, UpdateTaskDto dto) async {
    try {
      final response = await _dio.patch(
        '${ApiConfig.tasksEndpoint}/$id',
        data: dto.toJson(),
      );

      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Elimina una tarea
  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete('${ApiConfig.tasksEndpoint}/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Maneja los errores de Dio y los convierte en excepciones legibles
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Error de conexión: Tiempo de espera agotado');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'Error desconocido';

        switch (statusCode) {
          case 400:
            return Exception('Solicitud inválida: $message');
          case 404:
            return Exception('No encontrado: $message');
          case 500:
            return Exception('Error del servidor: $message');
          default:
            return Exception('Error HTTP $statusCode: $message');
        }

      case DioExceptionType.cancel:
        return Exception('Solicitud cancelada');

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return Exception('Sin conexión a internet');
        }
        return Exception('Error inesperado: ${error.message}');

      default:
        return Exception('Error desconocido');
    }
  }
}
