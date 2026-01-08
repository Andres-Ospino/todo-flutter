import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_display.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/tasks_provider.dart';
import '../providers/tasks_state.dart';
import '../widgets/create_task_dialog.dart';
import '../widgets/task_item.dart';

/// Pantalla principal de tareas
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar tareas al iniciar
    Future.microtask(
      () => ref.read(tasksNotifierProvider.notifier).loadTasks(),
    );
  }

  Future<void> _refreshTasks() async {
    await ref.read(tasksNotifierProvider.notifier).loadTasks();
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateTaskDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksNotifierProvider);
    final currentFilter = ref.watch(taskFilterProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final tasksCount = ref.watch(tasksCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          // Menú de filtros
          PopupMenuButton<TaskFilter>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar tareas',
            onSelected: (filter) {
              ref.read(taskFilterProvider.notifier).update((state) => filter);
            },
            itemBuilder: (context) => [
              for (final filter in TaskFilter.values)
                PopupMenuItem(
                  value: filter,
                  child: Row(
                    children: [
                      if (currentFilter == filter)
                        const Icon(Icons.check, size: 20)
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 8),
                      Text(filter.label),
                    ],
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCounter(
                  context,
                  'Total',
                  tasksCount.total,
                  Icons.checklist,
                ),
                _buildCounter(
                  context,
                  'Pendientes',
                  tasksCount.pending,
                  Icons.pending_actions,
                ),
                _buildCounter(
                  context,
                  'Completadas',
                  tasksCount.completed,
                  Icons.check_circle,
                ),
              ],
            ),
          ),
        ),
      ),
      body: tasksState.when(
        initial: () => const Center(
          child: Text('Listo para cargar tareas'),
        ),
        loading: () => const LoadingIndicator(
          message: 'Cargando tareas...',
        ),
        loaded: (tasks) {
          if (filteredTasks.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshTasks,
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: EmptyState(
                      message: currentFilter == TaskFilter.all
                          ? AppConstants.emptyTasksMessage
                          : 'No hay tareas ${currentFilter.label.toLowerCase()}',
                      hint: currentFilter == TaskFilter.all
                          ? AppConstants.emptyTasksHint
                          : null,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshTasks,
            child: ListView.builder(
              itemCount: filteredTasks.length,
              padding: const EdgeInsets.only(
                top: AppConstants.smallPadding,
                bottom: 80, // Espacio para el FAB
              ),
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return TaskItem(key: ValueKey(task.id), task: task);
              },
            ),
          );
        },
        error: (message) => ErrorDisplay(
          message: message,
          onRetry: _refreshTasks,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Tarea'),
      ),
    );
  }

  Widget _buildCounter(
    BuildContext context,
    String label,
    int count,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
