import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/theme_provider.dart'; // Import theme provider
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_display.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/sync_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/tasks_state.dart';
import '../widgets/task_dialog.dart';
import '../widgets/task_item.dart';
import '../widgets/task_filter_bar.dart';
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
                          Text(
                            'Resumen',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.outline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                           Row(
                             children: [
                               _SimpleCounter(
                                 label: 'Total', 
                                 count: tasksCount.total, 
                                 color: theme.colorScheme.primary
                               ),
                               const SizedBox(width: 16),
                               _SimpleCounter(
                                 label: 'Pendiente', 
                                 count: tasksCount.pending, 
                                 color: theme.colorScheme.tertiary 
                               ),
                             ],
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
                initial: () => const SliverFillRemaining(
                  child: Center(child: Text('Iniciando...')),
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
                        child: EmptyState(
                           message: 'No hay tareas encontradas',
                        ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add_task),
        label: const Text('Nueva', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
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
          )
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
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
              
              Text('Configuración', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              
              const Text('Tema', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system, 
                    label: Text('Sistema'), 
                    icon: Icon(Icons.brightness_auto)
                  ),
                  ButtonSegment(
                    value: ThemeMode.light, 
                    label: Text('Claro'), 
                    icon: Icon(Icons.light_mode)
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark, 
                    label: Text('Oscuro'), 
                    icon: Icon(Icons.dark_mode)
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (Set<ThemeMode> newSelection) {
                  ref.read(themeProvider.notifier).setTheme(newSelection.first);
                },
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Acerca de'),
                subtitle: const Text('To-Do App v1.0.0'),
                contentPadding: EdgeInsets.zero,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
