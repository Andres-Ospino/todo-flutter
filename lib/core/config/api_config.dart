import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Base URL de la API
  // Para desarrollo local usar:
  // - iOS Simulator: http://localhost:3000
  // - Android Emulator: http://10.0.2.2:3000
  // - Dispositivo físico: http://<TU_IP_LOCAL>:3000
  
  // Prioridad:
  // 1. .env file (runtime)
  // 2. --dart-define (compile-time)
  // 3. Default fallback
  static String get baseUrl {
    // Intenta leer de .env primero
    final envUrl = dotenv.env['API_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Fallback a dart-define o default
    return const String.fromEnvironment(
      'API_URL',
      defaultValue: 'http://localhost:3000',
    );
  }

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 5);
  static const Duration sendTimeout = Duration(seconds: 5);

  // Endpoints
  static const String tasksEndpoint = '/tasks';

  // Headers
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
