import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/task.dart';
import '../providers/tasks_provider.dart';
import 'task_dialog.dart';

/// Widget para mostrar un item individual de tarea con mejor UI y animaciones
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
        await HapticFeedback.heavyImpact(); 
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
        margin: EdgeInsets.zero,
        elevation: 0,
        color: task.completed 
            ? colorScheme.surfaceContainerHighest.withOpacity(0.4) 
            : colorScheme.surfaceContainer,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.lightImpact();
             ref.read(tasksNotifierProvider.notifier).toggleTaskCompletion(
                  task.id,
                  task.completed,
                );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16), // Adjusted padding for menu
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom Checkbox
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: task.completed,
                      activeColor: colorScheme.primary,
                      shape: const CircleBorder(),
                      side: BorderSide(color: colorScheme.outline, width: 2),
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        ref.read(tasksNotifierProvider.notifier).toggleTaskCompletion(
                              task.id,
                              task.completed,
                            );
                      },
                    ),
                  ).animate(target: task.completed ? 1 : 0)
                   .scale(duration: 200.ms, curve: Curves.easeInOutBack, begin: const Offset(1,1), end: const Offset(1.1, 1.1))
                   .then().scale(end: const Offset(1,1)),
                ),

                const SizedBox(width: 12),
                
                // Task info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                             decoration: task.completed ? TextDecoration.lineThrough : null,
                            color: task.completed 
                                ? colorScheme.outline 
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (task.description != null && task.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          task.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                             color: colorScheme.onSurfaceVariant,
                             height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: colorScheme.secondary),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(task.createdAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: colorScheme.outline),
                  onSelected: (value) {
                    if (value == 'edit') {
                      showDialog(
                        context: context,
                        builder: (context) => TaskDialog(task: task),
                      );
                    } else if (value == 'delete') {
                      _confirmAndDelete(context, ref);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outlined, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showDeleteConfirmation(context);
    if (confirmed == true) {
      ref.read(tasksNotifierProvider.notifier).deleteTask(task.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(AppConstants.taskDeletedSuccess),
            behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar tarea?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(AppConstants.confirmDeleteMessage),
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
