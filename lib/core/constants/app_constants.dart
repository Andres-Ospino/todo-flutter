class AppConstants {
  // App Info
  static const String appName = 'To-Do App';
  static const String appVersion = '1.0.0';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  
  static const double defaultElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Task Limits
  static const int maxTitleLength = 200;
  static const int maxDescriptionLength = 1000;
  
  // Paginación
  static const int tasksPerPage = 20;
  static const int initialPage = 1;
  
  // Messages
  static const String emptyTasksMessage = 'No hay tareas aún';
  static const String emptyTasksHint = 'Toca el botón + para crear una nueva tarea';
  static const String errorLoadingTasks = 'Error al cargar las tareas';
  static const String errorCreatingTask = 'Error al crear la tarea';
  static const String errorUpdatingTask = 'Error al actualizar la tarea';
  static const String errorDeletingTask = 'Error al eliminar la tarea';
  static const String taskCreatedSuccess = 'Tarea creada exitosamente';
  static const String taskUpdatedSuccess = 'Tarea actualizada';
  static const String taskDeletedSuccess = 'Tarea eliminada';
  static const String confirmDelete = '¿Eliminar esta tarea?';
  static const String confirmDeleteMessage = 'Esta acción no se puede deshacer';
  
  // Form Validation
  static const String titleRequired = 'El título es requerido';
  static const String titleTooLong = 'El título es demasiado largo';
  static const String descriptionTooLong = 'La descripción es demasiado larga';
  
  // Filter Labels
  static const String filterAll = 'Todas';
  static const String filterPending = 'Pendientes';
  static const String filterCompleted = 'Completadas';
}
