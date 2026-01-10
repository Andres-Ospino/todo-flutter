import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/tasks/data/datasources/task_local_datasource.dart';
import 'features/tasks/presentation/screens/tasks_screen.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  // Aseguramos que los bindings estén inicializados antes de cargar .env
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive
  await Hive.initFlutter();
  
  // Inicializar Local DataSource (abrir boxes)
  await TaskLocalDataSource().init();
  
  // Cargamos el archivo .env si existe
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Si no existe, no pasa nada, usaremos los defaults o dart-define
    print("No .env file found, using defaults.");
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme provider for changes
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      // Internationalization configuration
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('es', ''), // Spanish
      ],
      home: const TasksScreen(),
    );
  }
}
