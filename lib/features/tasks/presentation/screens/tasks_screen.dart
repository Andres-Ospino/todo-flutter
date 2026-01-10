import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_display.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/sync_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/tasks_state.dart';
import '../widgets/task_dialog.dart';
import '../widgets/task_item.dart';
import '../widgets/task_filter_bar.dart';
import '../widgets/settings_widgets.dart';
import 'dart:math';

/// Pantalla principal de tareas con UI Premium y Responsiva
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(tasksNotifierProvider.notifier).loadTasks(),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      ref.read(tasksNotifierProvider.notifier).loadMoreTasks();
    }
  }

  Future<void> _refreshTasks() async {
    await ref.read(tasksNotifierProvider.notifier).loadTasks(refresh: true);
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => const TaskDialog(),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true, // Allow true scrolling behavior
      builder: (context) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksNotifierProvider);
    final filteredTasks = ref.watch(filteredTasksProvider);
    final tasksCount = ref.watch(tasksCountProvider);
    final isSyncing = ref.watch(syncProvider);
    final theme = Theme.of(context);
    
    // Logic for Responsive Layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = Breakpoints.isDesktop(screenWidth);
    const double maxContentWidth = 800.0;
    final double horizontalPadding = max(0.0, (screenWidth - maxContentWidth) / 2);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshTasks,
        displacement: 100, 
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // 1. Modern Sliver App Bar (Full Width)
            SliverAppBar.large(
              title: const Text(AppConstants.appName),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: _showSettings,
                ),
                const SizedBox(width: 8),
              ],
              bottom: isSyncing 
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(4),
                      child: LinearProgressIndicator(
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                    )
                  : null,
            ),

            // 2. Filters & Stats Header (Centered content)
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const TaskFilterBar(),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SummaryTitle(),
                           _TaskCounters(
                             total: tasksCount.total,
                             pending: tasksCount.pending,
                           ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Task List
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: tasksState.when(
                initial: () => SliverFillRemaining(
                  child: Center(child: _InitializingText()),
                ),
                loading: () => const SliverFillRemaining(
                  child: LoadingIndicator(message: ''),
                ),
                error: (msg) => SliverFillRemaining(
                  child: ErrorDisplay(message: msg, onRetry: _refreshTasks),
                ),
                loaded: (tasks, hasMore, _) {
                  if (filteredTasks.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: FractionallySizedBox(
                        heightFactor: 0.6,
                        child: _EmptyTasksState(),
                      ),
                    );
                  }

                  if (isDesktop) {
                    return SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                           if (index == filteredTasks.length) {
                             return const Padding(
                               padding: EdgeInsets.all(24.0),
                               child: Center(child: CircularProgressIndicator()),
                             );
                           }
                           final task = filteredTasks[index];
                           return TaskItem(key: ValueKey(task.id), task: task)
                              .animate()
                              .fadeIn(duration: 400.ms, delay: (50 * index).ms);
                        },
                        childCount: filteredTasks.length + (hasMore ? 1 : 0),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == filteredTasks.length) {
                           return const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final task = filteredTasks[index];
                        return TaskItem(key: ValueKey(task.id), task: task)
                            .animate()
                            .fadeIn(duration: 400.ms, delay: (50 * index).ms)
                            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad);
                      },
                      childCount: filteredTasks.length + (hasMore ? 1 : 0),
                    ),
                  );
                },
              ),
            ),
            
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
      floatingActionButton: _AddTaskButton(onPressed: _showCreateDialog),
    );
  }
}

// Helper widgets with i18n
class _SummaryTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Resumen', // TODO: Add to l10n if needed
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.outline,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _TaskCounters extends StatelessWidget {
  final int total;
  final int pending;

  const _TaskCounters({required this.total, required this.pending});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _SimpleCounter(
          label: 'Total',
          count: total,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 16),
        _SimpleCounter(
          label: 'Pendiente',
          count: pending,
          color: theme.colorScheme.tertiary,
        ),
      ],
    );
  }
}

class _SimpleCounter extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _SimpleCounter({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _InitializingText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text('Iniciando...'); // Initializing state, rarely seen
  }
}

class _EmptyTasksState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(message: l10n.noTasks);
  }
}

class _AddTaskButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddTaskButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.add_task),
      label: Text(l10n.addTask, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

/// Settings Sheet extracted for better state management
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), // Reduced bottom padding slightly in favor of SafeArea
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // No drag handle here as it is provided by showModalBottomSheet(showDragHandle: true)
              
              const SettingsTitle(),
              const SizedBox(height: 24),
              
              const ThemeLabel(),
              const SizedBox(height: 12),
              ThemeSelector(
                themeMode: themeMode,
                onChanged: (mode) => ref.read(themeProvider.notifier).setTheme(mode),
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SettingsAboutTile(),
              const SizedBox(height: 12),
              const SettingsCloseButton(),
            ],
          ),
        ),
      ),
    );
  }
}
