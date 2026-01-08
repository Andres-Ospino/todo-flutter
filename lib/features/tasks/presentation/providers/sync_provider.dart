import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/task_local_datasource.dart';
import '../../data/repositories/task_repository.dart';
import 'tasks_provider.dart';

final syncProvider = StateNotifierProvider<SyncNotifier, bool>((ref) {
  final localDataSource = TaskLocalDataSource();
  final repository = ref.watch(taskRepositoryProvider);
  return SyncNotifier(localDataSource, repository, ref);
});

class SyncNotifier extends StateNotifier<bool> {
  final TaskLocalDataSource _localDataSource;
  final TaskRepository _repository;
  final Ref _ref;

  SyncNotifier(this._localDataSource, this._repository, this._ref) : super(false) {
    _init();
  }

  void _init() {
    // Escuchar cambios de conexión
    Connectivity().onConnectivityChanged.listen((results) {
        // En connectivity_plus 6+, results es List<ConnectivityResult>
        if (results.any((r) => r != ConnectivityResult.none)) {
            syncPendingActions();
        }
    });
  }

  Future<void> syncPendingActions() async {
    if (state) return; // Ya sincronizando
    
    // Verificar conexión real antes de intentar (opcional, pero buena práctica)
    // Aquí asumimos que si se llamó es porque hay red o se forzó.

    state = true;
    try {
      // Delegar la lógica de sincronización al repositorio
      await _repository.syncPendingActions();

      // Al finalizar, recargar tareas frescas del servidor para actualizar IDs y estados
      await _ref.read(tasksNotifierProvider.notifier).loadTasks();
      
    } catch (e) {
       print('❌ Error general en SyncNotifier: $e');
    } finally {
      state = false;
    }
  }
}
