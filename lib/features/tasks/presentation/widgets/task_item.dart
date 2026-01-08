import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/task.dart';
import '../providers/tasks_provider.dart';

/// Widget para mostrar un item individual de tarea con mejor UI
class TaskItem extends ConsumerWidget {
  final Task task;

  const TaskItem({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usamos el locale por defecto del sistema o EN
    final dateFormat = DateFormat('MMM d, h:mm a'); 
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        await HapticFeedback.heavyImpact(); // Changed from warningImpact
        if (context.mounted) {
           return await _showDeleteConfirmation(context);
        }
        return false;
      },
      onDismissed: (direction) {
        ref.read(tasksNotifierProvider.notifier).deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppConstants.taskDeletedSuccess),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Eliminar', style: TextStyle(color: colorScheme.onErrorContainer, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
          ],
        ),
      ),
      child: Card(
        margin: EdgeInsets.zero, // Manejado por el ListView
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
             ref.read(tasksNotifierProvider.notifier).toggleTaskCompletion(
                  task.id,
                  task.completed,
                );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Alineación superior para textos largos
              children: [
                // Custom Checkbox animado (usando M3 checkbox por ahora)
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: task.completed,
                    activeColor: colorScheme.primary,
                    shape: const CircleBorder(),
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      ref.read(tasksNotifierProvider.notifier).toggleTaskCompletion(
                            task.id,
                            task.completed,
                          );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                
                // Task info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8), // Alinear visualmente con checkbox
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: task.completed ? TextDecoration.lineThrough : null,
                          color: task.completed 
                              ? colorScheme.outline 
                              : colorScheme.onSurface,
                        ),
                      ),
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                             color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dateFormat.format(task.createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
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
        title: const Text('¿Eliminar tarea?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(AppConstants.confirmDeleteMessage),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
