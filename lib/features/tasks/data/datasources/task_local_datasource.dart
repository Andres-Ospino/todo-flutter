import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/task.dart';

/// Local Datasource using Hive
class TaskLocalDataSource {
  static const String boxName = 'tasks_cache';
  static const String pendingBoxName = 'pending_actions';

  Future<void> init() async {
    // We attempt to open boxes here, but we also check in _getBox
    if (!Hive.isBoxOpen(boxName)) await Hive.openBox(boxName);
    if (!Hive.isBoxOpen(pendingBoxName)) await Hive.openBox(pendingBoxName);
  }

  // Helper to ensure box is open (Lazy loading for robustness)
  Future<Box> _getBox(String name) async {
    if (!Hive.isBoxOpen(name)) {
      return await Hive.openBox(name);
    }
    return Hive.box(name);
  }

  /// Save tasks to cache
  Future<void> cacheTasks(List<Task> tasks) async {
    final box = await _getBox(boxName);
    await box.clear();
    // Convert Task entities to Map for storage (simple json)
    final Map<String, dynamic> data = {
      for (var t in tasks) t.id: _taskToMap(t)
    };
    await box.putAll(data);
  }

  /// Get cached tasks
  Future<List<Task>> getCachedTasks() async {
    final box = await _getBox(boxName);
    if (box.isEmpty) return [];
    
    final tasks = <Task>[];
    for (var i = 0; i < box.length; i++) {
        final map = Map<String, dynamic>.from(box.getAt(i));
        tasks.add(_mapToTask(map));
    }
    return tasks;
  }

  // --- Pending Actions Queue ---
  
  Future<void> addPendingAction(PendingAction action) async {
    final box = await _getBox(pendingBoxName);
    await box.add(action.toMap());
  }

  Future<List<PendingAction>> getPendingActions() async {
    final box = await _getBox(pendingBoxName);
    final actions = <PendingAction>[];
    for (var i = 0; i < box.length; i++) {
        final key = box.keyAt(i); // Use REAL Hive key
        final map = Map<String, dynamic>.from(box.getAt(i));
        actions.add(PendingAction.fromMap(map, key)); 
    }
    return actions;
  }

  Future<void> removePendingAction(int key) async {
    final box = await _getBox(pendingBoxName);
    await box.delete(key); // Use delete(key) instead of deleteAt(index)
  }
  
  // Helpers
  Map<String, dynamic> _taskToMap(Task t) => {
    'id': t.id,
    'title': t.title,
    'description': t.description,
    'completed': t.completed,
    'createdAt': t.createdAt.toIso8601String(),
  };

  Task _mapToTask(Map<String, dynamic> map) => Task(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    completed: map['completed'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}

enum ActionType { create, update, delete }

class PendingAction {
  final int? key; // Hive key
  final ActionType type;
  final Map<String, dynamic> payload;

  PendingAction({this.key, required this.type, required this.payload});

  Map<String, dynamic> toMap() => {
    'type': type.toString(),
    'payload': payload,
  };

  factory PendingAction.fromMap(Map<String, dynamic> map, int key) {
    return PendingAction(
      key: key,
      type: ActionType.values.firstWhere((e) => e.toString() == map['type']),
      payload: Map<String, dynamic>.from(map['payload']),
    );
  }
}
