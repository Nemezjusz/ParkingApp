// lib/blocs/theme_bloc.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

// States
class ThemeState {
  final ThemeData themeData;
  final bool isDarkMode;

  ThemeState({required this.themeData, required this.isDarkMode});
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc()
      : super(ThemeState(
          themeData: _lightTheme,
          isDarkMode: false,
        )) {
    on<ToggleTheme>((event, emit) {
      final newIsDarkMode = !state.isDarkMode;
      if (newIsDarkMode) {
        emit(ThemeState(
          themeData: _darkTheme,
          isDarkMode: newIsDarkMode,
        ));
      } else {
        emit(ThemeState(
          themeData: _lightTheme,
          isDarkMode: newIsDarkMode,
        ));
      }
    });
  }

  // Definicja motywu jasnego
  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFc6ad8f), // #c6ad8f
    scaffoldBackgroundColor: const Color(0xFFfef3e9), // #fef3e9
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
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFc6ad8f),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFc6ad8f)),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(const Color(0xFFc6ad8f)),
      trackColor: MaterialStateProperty.all(
          const Color(0xFFc6ad8f).withOpacity(0.5)),
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

  // Definicja motywu ciemnego
  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFc6ad8f), // #c6ad8f
    scaffoldBackgroundColor: const Color(0xFF22333c), // #22333c
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
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFc6ad8f),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFFc6ad8f)),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(const Color(0xFFc6ad8f)),
      trackColor: MaterialStateProperty.all(
          const Color(0xFFc6ad8f).withOpacity(0.5)),
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
