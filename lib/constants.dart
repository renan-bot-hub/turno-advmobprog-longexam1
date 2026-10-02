import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

var host = dotenv.env['HOST'] ?? AppConstants.baseUrl;

// ignore_for_file: constant_identifier_names
const Color FB_PRIMARY = Color(0xFF5865F2);
const Color FB_SECONDARY = Color(0xFF57F287);
const Color FB_DARK_PRIMARY = Color(0xFF2C2F33);
const Color FB_LIGHT_PRIMARY = Color(0xFF36393F);
const Color FB_TEXT_COLOR_WHITE = Color(0xFFDCDCDC);

class AppColors {
  static const Color primary = Color(0xFF1877F2);
  static const Color bgLight = Color(0xFFF0F2F5);
  static const Color bgDark = Color(0xFF18191A);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1E21);
  static const Color textSecondary = Color(0xFF65676B);
  static const Color border = Color(0xFFE4E6EB);
}

class AppStrings {
  static const String appName = 'NansuX';
}

class AppConstants {
  static const String baseUrl = 'https://dummyjson.com';
}