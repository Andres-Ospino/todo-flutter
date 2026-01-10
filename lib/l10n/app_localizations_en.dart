// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'To-Do App';

  @override
  String get tasksTitle => 'Tasks';

  @override
  String get addTask => 'Add Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String get taskTitle => 'Title';

  @override
  String get taskDescription => 'Description';

  @override
  String get taskCompleted => 'Completed';

  @override
  String get taskPending => 'Pending';

  @override
  String get noTasks => 'No tasks available';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
      zero: 'No tasks',
    );
    return '$_temp0';
  }

  @override
  String get taskCreated => 'Task created successfully';

  @override
  String get taskUpdated => 'Task updated successfully';

  @override
  String get taskDeleted => 'Task deleted successfully';

  @override
  String get errorLoadingTasks => 'Error loading tasks';

  @override
  String get errorCreatingTask => 'Error creating task';

  @override
  String get errorUpdatingTask => 'Error updating task';

  @override
  String get errorDeletingTask => 'Error deleting task';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get refresh => 'Refresh';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemMode => 'System Default';
}
