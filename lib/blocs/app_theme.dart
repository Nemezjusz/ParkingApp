// lib/blocs/theme_bloc.dart
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFc6ad8f), // #c6ad8f
    scaffoldBackgroundColor: const Color(0xFFfef3e9), // #fef3e9
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFc6ad8f),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFc6ad8f),
      secondary: Color(0xFFebe0d6),
      surface: Color(0xFFebe0d6),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.black,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.black),
      headlineMedium: TextStyle(color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      titleLarge: TextStyle(
          color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
      titleSmall: TextStyle(
          color: Colors.black, fontSize: 20, fontWeight: FontWeight.normal),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFc6ad8f)),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(const Color(0xFFc6ad8f)),
      trackColor:
          MaterialStateProperty.all(const Color(0xFFc6ad8f).withOpacity(0.5)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFfef3e9),
      selectedItemColor: Color(0xFFc6ad8f),
      unselectedItemColor: Colors.grey,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFc6ad8f),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFc6ad8f), // #c6ad8f
    scaffoldBackgroundColor: const Color(0xFF22333c), // #22333c
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFc6ad8f),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFc6ad8f),
      secondary: Color(0xFFebe0d6),
      surface: Color(0xFF22333c),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.white),
      headlineMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(
          color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
      titleSmall: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.normal),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFc6ad8f)),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(const Color(0xFFc6ad8f)),
      trackColor:
          MaterialStateProperty.all(const Color(0xFFc6ad8f).withOpacity(0.5)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF22333c),
      selectedItemColor: Color(0xFFc6ad8f),
      unselectedItemColor: Colors.grey,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFc6ad8f),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
