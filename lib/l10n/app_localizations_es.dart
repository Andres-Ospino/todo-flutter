// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'App de Tareas';

  @override
  String get tasksTitle => 'Tareas';

  @override
  String get addTask => 'Agregar Tarea';

  @override
  String get editTask => 'Editar Tarea';

  @override
  String get deleteTask => 'Eliminar Tarea';

  @override
  String get taskTitle => 'Título';

  @override
  String get taskDescription => 'Descripción';

  @override
  String get taskCompleted => 'Completada';

  @override
  String get taskPending => 'Pendiente';

  @override
  String get noTasks => 'No hay tareas disponibles';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas',
      one: '1 tarea',
      zero: 'No hay tareas',
    );
    return '$_temp0';
  }

  @override
  String get taskCreated => 'Tarea creada exitosamente';

  @override
  String get taskUpdated => 'Tarea actualizada exitosamente';

  @override
  String get taskDeleted => 'Tarea eliminada exitosamente';

  @override
  String get errorLoadingTasks => 'Error al cargar las tareas';

  @override
  String get errorCreatingTask => 'Error al crear la tarea';

  @override
  String get errorUpdatingTask => 'Error al actualizar la tarea';

  @override
  String get errorDeletingTask => 'Error al eliminar la tarea';

  @override
  String get titleRequired => 'El título es obligatorio';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get refresh => 'Actualizar';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get lightMode => 'Modo Claro';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get systemMode => 'Sistema';
}
