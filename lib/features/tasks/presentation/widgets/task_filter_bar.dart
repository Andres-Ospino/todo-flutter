import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tasks_provider.dart';
import '../providers/tasks_state.dart';

class TaskFilterBar extends ConsumerWidget {
  const TaskFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(taskFilterProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'Todas',
            icon: Icons.list_alt,
            isSelected: currentFilter == TaskFilter.all,
            onSelected: () =>
                ref.read(taskFilterProvider.notifier).state = TaskFilter.all,
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 12),
          _FilterChip(
            label: 'Pendientes',
            icon: Icons.check_box_outline_blank,
            isSelected: currentFilter == TaskFilter.pending,
            onSelected: () =>
                ref.read(taskFilterProvider.notifier).state = TaskFilter.pending,
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 12),
          _FilterChip(
            label: 'Completadas',
            icon: Icons.check_circle_outline,
            isSelected: currentFilter == TaskFilter.completed,
            onSelected: () =>
                ref.read(taskFilterProvider.notifier).state = TaskFilter.completed,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelected;
  final ColorScheme colorScheme;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
      ),
      label: Text(label),
      onPressed: onSelected,
      backgroundColor: isSelected ? colorScheme.primary : colorScheme.surfaceContainerLow,
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide.none, // Cleaner look
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: isSelected ? 2 : 0,
    );
  }
}
