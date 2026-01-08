import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/task_local_datasource.dart';
import '../repositories/task_repository.dart';
import '../../presentation/providers/tasks_provider.dart';

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
      final pendingActions = await _localDataSource.getPendingActions();
      if (pendingActions.isEmpty) {
        state = false;
        return;
      }

      print('🔄 Sincronizando ${pendingActions.length} acciones pendientes...');

      for (var action in pendingActions) {
        try {
          switch (action.type) {
            case ActionType.create:
             await _repository.createTask(
                title: action.payload['title'],
                description: action.payload['description'],
              );
              // Nota: El repositorio ya maneja la creación "real". 
              // El ID temporal se descarta en el server, y el server devuelve el real.
              // En un sistema real complejo, tendríamos que mapear ID temp -> ID real en local.
              // Para este MVP, simplemente creamos la tarea de nuevo en el server.
              // Podría haber duplicados si no limpiamos el cache local correctamente después.
              break;
            
            case ActionType.update:
              await _repository.toggleTaskCompletion(
                action.payload['id'],
                action.payload['completed'],
              );
              break;

            case ActionType.delete:
              await _repository.deleteTask(action.payload['id']);
              break;
          }
          
          // Si éxito, borrar de la cola
          if (action.key != null) {
            await _localDataSource.removePendingAction(action.key!);
          }
        } catch (e) {
          print('❌ Error sincronizando acción: $e');
          // Si falla por red, se queda en la cola para el siguiente intento.
          // Si es otro error (400, 500), se debería borrar o marcar como fallido.
          // Aquí simplificamos y solo reintentamos.
        }
      }

      // Al finalizar, recargar tareas frescas del servidor
      await _ref.read(tasksNotifierProvider.notifier).loadTasks();
      
    } finally {
      state = false;
    }
  }
}
