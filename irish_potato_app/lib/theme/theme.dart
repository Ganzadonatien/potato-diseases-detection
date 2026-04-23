import 'package:flutter/material.dart';

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF2E7D32),
  onPrimary: Colors.white,
  primaryContainer: Color(0xFF81C784),
  onPrimaryContainer: Colors.black,
  secondary: Color(0xFF388E3C),
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFF66BB6A),
  onSecondaryContainer: Colors.black,
  tertiary: Color(0xFF1B5E20),
  onTertiary: Colors.white,
  tertiaryContainer: Color(0xFF4CAF50),
  onTertiaryContainer: Colors.black,
  error: Color(0xFFD32F2F),
  onError: Colors.white,
  errorContainer: Color(0xFFE57373),
  onErrorContainer: Colors.black,
  background: Color(0xFFF5F5F5),
  onBackground: Colors.black,
  surface: Colors.white,
  onSurface: Colors.black,
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF81C784),
  onPrimary: Colors.black,
  primaryContainer: Color(0xFF2E7D32),
  onPrimaryContainer: Colors.white,
  secondary: Color(0xFF66BB6A),
  onSecondary: Colors.black,
  secondaryContainer: Color(0xFF388E3C),
  onSecondaryContainer: Colors.white,
  tertiary: Color(0xFF4CAF50),
  onTertiary: Colors.black,
  tertiaryContainer: Color(0xFF1B5E20),
  onTertiaryContainer: Colors.white,
  error: Color(0xFFE57373),
  onError: Colors.black,
  errorContainer: Color(0xFFD32F2F),
  onErrorContainer: Colors.white,
  background: Color(0xFF303030),
  onBackground: Colors.white,
  surface: Color(0xFF424242),
  onSurface: Colors.white,
);

ThemeData LightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: lightColorScheme,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF2E7D32)),
      foregroundColor: MaterialStateProperty.all<Color>(
        Colors.white,
      ), // text color
      elevation: MaterialStateProperty.all<double>(5.0), // shadow
      padding: MaterialStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Adjust as needed
        ),
      ),
    ),
  ),
);

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: darkColorScheme,
);
