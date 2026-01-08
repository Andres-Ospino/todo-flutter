# Frontend - To-Do App (Flutter)

App móvil desarrollada con Flutter. Se conecta al backend NestJS para gestionar las tareas.

## 📋 Requisitos
- Flutter SDK instalado.
- Un dispositivo físico o emulador (Android/iOS).

## 🚀 Cómo correr la app

1.  **Instalar dependencias:**
    ```bash
    flutter pub get
    ```

2.  **Generar código (Riverpod/Freezed):**
    El proyecto usa generación de código para inmutabilidad y JSON serialization. Si ves errores de imports faltantes, corre:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

3.  **Ejecutar:**
    ```bash
    flutter run
    ```

### ⚠️ Nota Importante sobre la API en Emuladores
Si estás corriendo el backend localmente en `localhost:3000`:
- **iOS Simulator**: Funciona directo con `localhost:3000`.
- **Android Emulator**: Debes usar `10.0.2.2:3000` (porque `localhost` es el propio dispositivo Android).
- **Dispositivo Físico**: Asegúrate de que el teléfono y tu PC estén en la misma red y usa la IP de tu PC (ej. `192.168.1.XX:3000`).

Puedes configurar esto en `lib/core/config/api_config.dart` o pasar la URL al compilar:
```bash
flutter run --dart-define=API_URL=http://10.0.2.2:3000
```

## � Arquitectura y Estado

Decidí usar **Clean Architecture** para mantener el código ordenado y testearble:
- **Data**: Repositorios y Modelos.
- **Domain**: Entidades puras (sin dependencias de Flutter).
- **Presentation**: UI y State Management.

Para el estado elegí **Riverpod** porque ofrece un manejo de dependencias muy robusto y seguro (compile-safe), evitando muchos problemas comunes de los Providers tradicionales.

## ✨ Features Implementadas
- Listado de tareas con **Scroll Infinito**.
- Crear, Completar y Eliminar tareas.
- Manejo de estados de carga (Loading) y errores.
- Diseño responsivo (Material 3).

## 🧪 Tests
Puedes correr los tests unitarios con:
```bash
flutter test
```
