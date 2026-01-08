import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/task.dart';
import '../providers/tasks_provider.dart';

/// Widget para mostrar un item individual de tarea
class TaskItem extends ConsumerWidget {
  final Task task;

  const TaskItem({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        ref.read(tasksNotifierProvider.notifier).deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.taskDeletedSuccess),
            duration: Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: AppConstants.smallPadding,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          onTap: () {
            // Toggle completed status
            ref.read(tasksNotifierProvider.notifier).toggleTaskCompletion(
                  task.id,
                  task.completed,
                );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                // Checkbox
                Checkbox(
                  value: task.completed,
                  onChanged: (value) {
                    ref.read(tasksNotifierProvider.notifier).toggleTaskCompletion(
                          task.id,
                          task.completed,
                        );
                  },
                ),
                const SizedBox(width: 12),
                
                // Task info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              decoration: task.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.completed
                                  ? Theme.of(context).colorScheme.onSurfaceVariant
                                  : null,
                            ),
                      ),
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(task.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
                
                // Delete icon
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final confirmed = await _showDeleteConfirmation(context);
                    if (confirmed == true) {
                      ref.read(tasksNotifierProvider.notifier).deleteTask(task.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(AppConstants.taskDeletedSuccess),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  tooltip: 'Eliminar tarea',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppConstants.confirmDelete),
        content: const Text(AppConstants.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
