import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/task.dart';
import '../providers/tasks_provider.dart';

/// Diálogo para crear o editar una tarea
class TaskDialog extends ConsumerStatefulWidget {
  final Task? task; // Si es null, es modo CREAR. Si existe, es modo EDITAR.

  const TaskDialog({super.key, this.task});

  @override
  ConsumerState<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends ConsumerState<TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    
    final l10n = AppLocalizations.of(context)!;

    try {
      if (_isEditing) {
        // Lógica de actualización (TODO: Add update method to notifier if not exists)
        // Por ahora simulamos update si existe el método, sino hay que agregarlo
         // await ref.read(tasksNotifierProvider.notifier).updateTask(...)
         // Asumo que necesitamos agregar updateTask al notifier
         // Por ahora implementación de create para probar el refactor, luego update.
         await ref.read(tasksNotifierProvider.notifier).updateTask(
           widget.task!.id,
           title: _titleController.text.trim(),
           description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
         );
      } else {
        await ref.read(tasksNotifierProvider.notifier).createTask(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
            );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? l10n.taskUpdated : l10n.taskCreated),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
             behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(_isEditing ? l10n.editTask : l10n.addTask),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.taskTitle,
                  hintText: 'Ej: Comprar leche',
                  prefixIcon: const Icon(Icons.title),
                ),
                maxLength: AppConstants.maxTitleLength,
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.titleRequired;
                  }
                  if (value.length > AppConstants.maxTitleLength) {
                    return AppConstants.titleTooLong;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.taskDescription,
                  hintText: 'Detalles adicionales...',
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLength: AppConstants.maxDescriptionLength,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value != null &&
                      value.length > AppConstants.maxDescriptionLength) {
                    return AppConstants.descriptionTooLong;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? l10n.save : l10n.addTask),
        ),
      ],
    );
  }
}
