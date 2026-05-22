import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color darkBackground = Color(0xFF1a1a1a);
  static const Color burgundyHeader = Color(0xFF7d3f2e);
  static const Color goldAccent = Color(0xFFd4a574);
  static const Color blueButton = Color(0xFF0066ff);
  static const Color lightGray = Color(0xFFf5f5f5);
  static const Color darkGray = Color(0xFF808080);
  static const Color cardGray = Color(0xFFe8e8e8);
  static const Color accentRed = Color(0xFFff4444);

  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: burgundyHeader,
        elevation: 4,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: goldAccent,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: goldAccent),
      ),
      colorScheme: ColorScheme.dark(
        primary: burgundyHeader,
        secondary: goldAccent,
        surface: darkBackground,
        error: accentRed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: blueButton,
          foregroundColor: lightGray,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: blueButton),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: blueButton,
          side: const BorderSide(color: blueButton),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardGray,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: goldAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: darkGray),
        hintStyle: const TextStyle(color: darkGray),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: goldAccent,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: goldAccent,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: lightGray,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: lightGray, fontSize: 16),
        bodyMedium: TextStyle(color: lightGray, fontSize: 14),
      ),
      dividerColor: darkGray,
      iconTheme: const IconThemeData(color: goldAccent),
      listTileTheme: const ListTileThemeData(
        textColor: lightGray,
        iconColor: goldAccent,
        tileColor: burgundyHeader,
      ),
    );
  }
}
