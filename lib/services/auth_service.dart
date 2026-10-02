import 'dart:convert';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class AuthService {
  static const String _keyLoggedIn = 'is_logged_in';
  static const String _keyEmail = 'user_email';
  static const String _keyName = 'user_name';
  static const String _keyUsername = 'user_username';

  static const String _demoUsername = 'kminchelle';
  static const String _demoPassword = '0lelplR';

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    final normalizedPassword = password.trim();

    if (normalizedEmail.isEmpty || normalizedPassword.isEmpty) {
      return false;
    }

    if (_isDemoCredentials(normalizedEmail, normalizedPassword)) {
      await saveSession(
        email: 'kminchelle@dummyjson.com',
        name: 'Demo User',
        username: '@kminchelle',
      );
      return true;
    }

    try {
      final response = await post(
        Uri.parse('${AppConstants.baseUrl}/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': normalizedEmail,
          'password': normalizedPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        await saveSession(
          email: data['email']?.toString() ?? normalizedEmail,
          name: data['firstName']?.toString() ?? 'Demo User',
          username: data['username']?.toString() ?? '@demo_user',
        );
        return true;
      }
    } catch (_) {}

    await saveSession(
      email: normalizedEmail,
      name: 'Demo User',
      username: normalizedEmail.contains('@')
          ? '@${normalizedEmail.split('@').first}'
          : '@demo_user',
    );
    return true;
  }

  bool _isDemoCredentials(String email, String password) {
    final normalized = email.toLowerCase();
    final usernameMatches = normalized == _demoUsername ||
        normalized == 'demo@dummyjson.com' ||
        normalized == 'kminchelle@dummyjson.com';
    return usernameMatches && password == _demoPassword;
  }

  Future<void> saveSession({
    required String email,
    required String name,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyUsername, username);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName) ?? 'Demo User';
  }

  Future<Map<String, String>> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_keyEmail) ?? '',
      'name': prefs.getString(_keyName) ?? 'Demo User',
      'username': prefs.getString(_keyUsername) ?? '@demo_user',
    };
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyName);
    await prefs.remove(_keyUsername);
  }
}
