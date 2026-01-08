import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/tasks_provider.dart';

/// Diálogo para crear una nueva tarea
class CreateTaskDialog extends ConsumerStatefulWidget {
  const CreateTaskDialog({super.key});

  @override
  ConsumerState<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends ConsumerState<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(tasksNotifierProvider.notifier).createTask(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppConstants.taskCreatedSuccess),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppConstants.errorCreatingTask}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
    return AlertDialog(
      title: const Text('Nueva Tarea'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Comprar leche',
                prefixIcon: Icon(Icons.title),
              ),
              maxLength: AppConstants.maxTitleLength,
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppConstants.titleRequired;
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
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Detalles adicionales...',
                prefixIcon: Icon(Icons.description),
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
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _createTask,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Crear'),
        ),
      ],
    );
  }
}
