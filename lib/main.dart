import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/tasks/data/datasources/task_local_datasource.dart';
import 'features/tasks/presentation/screens/tasks_screen.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const TasksScreen(),
    );
  }
}
