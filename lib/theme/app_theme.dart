import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF00916E),
        unselectedItemColor: Colors.grey,
      ),
      textTheme: const TextTheme(
        // Setting default text color to be black
        labelLarge: TextStyle(color: Colors.black),
        displayLarge: TextStyle(color: Colors.black),
        displayMedium: TextStyle(color: Colors.black),
        displaySmall: TextStyle(color: Colors.black),
        headlineMedium: TextStyle(color: Colors.black),
        headlineSmall: TextStyle(color: Colors.black),
        titleLarge: TextStyle(color: Colors.black),
        titleMedium: TextStyle(color: Colors.black),
        titleSmall: TextStyle(color: Colors.black),
        bodySmall: TextStyle(color: Colors.black),
        labelSmall: TextStyle(color: Colors.black),
      ),
    );
  }
}
