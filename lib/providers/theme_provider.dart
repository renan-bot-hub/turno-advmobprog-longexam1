import 'package:flutter/material.dart';
import '../constants.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Color(0xFFF2F3F5),
    colorScheme: const ColorScheme.light(
      primary: FB_PRIMARY,
      surface: Colors.white,
      onSurface: Color(0xFF2C2F33),
      onPrimary: Color(0xFFF2F3F5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF2C2F33),
    ),
    cardColor: Colors.white,
  );

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: FB_DARK_PRIMARY,
    colorScheme: const ColorScheme.dark(
      primary: FB_PRIMARY,
      surface: FB_LIGHT_PRIMARY,
      onSurface: FB_TEXT_COLOR_WHITE,
      onPrimary: FB_TEXT_COLOR_WHITE,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: FB_LIGHT_PRIMARY,
      foregroundColor: FB_TEXT_COLOR_WHITE,
    ),
    cardColor: FB_LIGHT_PRIMARY,
  );

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}