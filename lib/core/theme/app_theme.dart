import 'package:flutter/material.dart';

class AppTheme {
  // Colores base - Violeta y Teal para mayor viveza
  static const Color _primaryColor = Color(0xFF6366F1); // Indigo 500
  static const Color _secondaryColor = Color(0xFF14B8A6); // Teal 500
  static const Color _errorColor = Color(0xFFEF4444); // Red 500
  
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
        primary: _primaryColor,
        secondary: _secondaryColor,
        error: _errorColor,
      ),
      
      // Typography - Google Fonts se pueden añadir después si se desea
      // Por ahora usamos la default mejorada de M3
      
      // AppBar
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0, // Flat always
      ),
      
      // Card
      cardTheme: CardThemeData(
        elevation: 0, // Flat style modern
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      
      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
      ),
      
      // Chips (para filtros)
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        backgroundColor: Colors.grey.shade100,
        selectedColor: _primaryColor.withOpacity(0.1),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
  
  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
        primary: _primaryColor, // Maintain branding in dark
        secondary: _secondaryColor,
        error: _errorColor,
        surface: const Color(0xFF1F2937), // Cool gray 800
      ),
      
      scaffoldBackgroundColor: const Color(0xFF111827), // Cool gray 900
      
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
       
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF374151), // Cool gray 700
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
      ),
      
       chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        backgroundColor: const Color(0xFF374151),
        selectedColor: _primaryColor.withOpacity(0.2),
         labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
