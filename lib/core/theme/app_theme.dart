import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color _lightPrimaryColor = Color(0xFF006C35);
  static const Color _lightBackgroundColor = Color(0xFFF8F9FA);
  static const Color _lightSurfaceColor = Colors.white;
  static const Color _lightTextColor = Colors.black87;

  // Dark Theme Colors
  static const Color _darkPrimaryColor = Color(0xFF00A651);
  static const Color _darkBackgroundColor = Color(0xFF0D1117);
  static const Color _darkSurfaceColor = Color(0xFF161B22);
  static const Color _darkTextColor = Colors.white70;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _lightPrimaryColor,
      surface: _lightSurfaceColor,
      onSurface: _lightTextColor,
      onPrimary: Colors.white,
    ),
    scaffoldBackgroundColor: _lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightSurfaceColor,
      foregroundColor: _lightTextColor,
      elevation: 0,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      surface: _darkSurfaceColor,
      onSurface: _darkTextColor,
      onPrimary: Colors.black,
    ),
    scaffoldBackgroundColor: _darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkSurfaceColor,
      foregroundColor: _darkTextColor,
      elevation: 0,
    ),
  );
}
