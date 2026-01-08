import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cambiamos a 'Material3' default preset or 'BrandBlue' for safer light mode
  // The user didn't like the light mode, often because 'Indigo' can be too saturated or low contrast on some shades.
  // Let's try 'DeepBlue' (Scheme.deepBlue) which is very standard, or tweak the current ONE.
  // We will stick to Indigo but improve the surface mode.
  static const FlexScheme _scheme = FlexScheme.indigo;

  /// Tema Claro Premium Refinado
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      scheme: _scheme,
      useMaterial3: true,
      // Usamos 'highScaffoldLowSurface' para que el fondo sea blanco/gris claro 
      // y las tarjetas tengan un color ligeramente distinto (surface), dando mejor contraste y profundidad.
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface, 
      blendLevel: 7,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        // Card styling
        cardElevation: 1, // Un poco de elevación para separar del fondo
        cardRadius: 16.0,
        // Inputs
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 16.0,
        inputDecoratorUnfocusedBorderIsColored: false, // Cleaner look
        // FAB
        fabUseShape: true,
        fabRadius: 16.0,
        // Chip
        chipRadius: 12.0,
        chipSchemeColor: SchemeColor.primary,
        // PopupMenu
        popupMenuRadius: 12.0,
        popupMenuElevation: 3.0,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: VisualDensity.standard,
      fontFamily: GoogleFonts.outfit().fontFamily,
    );
  }

  /// Tema Oscuro Premium
  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      scheme: _scheme,
      useMaterial3: true,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        cardElevation: 0.0,
        cardRadius: 16.0,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorRadius: 16.0,
        inputDecoratorUnfocusedBorderIsColored: false,
        fabUseShape: true,
        fabRadius: 16.0,
        checkboxSchemeColor: SchemeColor.primary,
        popupMenuRadius: 12.0,
        popupMenuElevation: 3.0,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: VisualDensity.standard,
      fontFamily: GoogleFonts.outfit().fontFamily,
    );
  }
}
