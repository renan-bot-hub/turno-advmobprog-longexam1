import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user.dart';

class UserService {
  static bool isValidEmail(String email) =>
      RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(email.trim());

  Map<String, dynamic> data = {};

  Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String username,
    required String password,
    required String email,
    required String mobile,
    required int age,
    required String gender,
  }) async {
    final sanitizedUsername = username.trim();
    final sanitizedPassword = password.trim();
    final sanitizedEmail = email.trim().toLowerCase();

    if (sanitizedUsername.isEmpty || sanitizedPassword.isEmpty) {
      throw Exception('Username and password are required');
    }

    if (!isValidEmail(sanitizedEmail)) {
      throw Exception('Enter a valid email address');
    }

    final prefs = await SharedPreferences.getInstance();
    final storedUsers = prefs.getStringList('registered_users') ?? [];
    final users = storedUsers
        .map((value) => jsonDecode(value) as Map<String, dynamic>)
        .toList();

    final usernameExists = users.any(
      (user) =>
          (user['username'] ?? '').toString().toLowerCase() ==
          sanitizedUsername.toLowerCase(),
    );

    if (usernameExists) {
      throw Exception('Username already exists');
    }

    final emailExists = users.any(
      (user) =>
          (user['email'] ?? '').toString().toLowerCase() == sanitizedEmail,
    );

    if (emailExists) {
      throw Exception('Email is already registered');
    }

    final userData = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'username': sanitizedUsername,
      'email': sanitizedEmail,
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'gender': gender,
      'age': age,
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
      'accessToken': 'local-${DateTime.now().millisecondsSinceEpoch}',
      'refreshToken': 'local-refresh-${DateTime.now().millisecondsSinceEpoch}',
      'token': 'local-${DateTime.now().millisecondsSinceEpoch}',
      'password': sanitizedPassword,
      'mobile': mobile.trim(),
      'coverImage': '',
    };

    users.add(userData);
    await prefs.setStringList(
      'registered_users',
      users.map((user) => jsonEncode(user)).toList(),
    );

    await saveUserData(userData);
    return userData;
  }

  Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) async {
    try {
      final response = await post(
        Uri.parse('$host/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'expiresInMins': 60,
        }),
      );

      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
        await saveUserData(data);
        return data;
      }
    } catch (_) {}

    final localUser = await _loginLocalUser(username, password);
    if (localUser != null) {
      await saveUserData(localUser);
      return localUser;
    }

    throw Exception('Username and password do not match');
  }

  Future<Map<String, dynamic>?> _loginLocalUser(
    String username,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsers = prefs.getStringList('registered_users') ?? [];

    for (final value in storedUsers) {
      final user = jsonDecode(value) as Map<String, dynamic>;
      final savedUsername = (user['username'] ?? '').toString();
      final savedPassword = (user['password'] ?? '').toString();

      final savedEmail = (user['email'] ?? '').toString().toLowerCase();
      final identifier = username.trim().toLowerCase();
      final matchesIdentifier =
          savedUsername.toLowerCase() == identifier || savedEmail == identifier;

      if (matchesIdentifier && savedPassword == password.trim()) {
        return {
          'id': user['id'] ?? 0,
          'username': savedUsername,
          'email': user['email'] ?? '$savedUsername@turno.local',
          'firstName': user['firstName'] ?? 'Turno',
          'lastName': user['lastName'] ?? 'User',
          'gender': user['gender'] ?? 'Prefer not to say',
          'age': user['age'] ?? 0,
          'mobile': user['mobile'] ?? '',
          'coverImage': user['coverImage'] ?? '',
          'image':
              user['image'] ??
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330',
          'accessToken': user['accessToken'] ?? 'local-token',
          'refreshToken': user['refreshToken'] ?? 'local-refresh',
          'token': user['token'] ?? user['accessToken'] ?? 'local-token',
        };
      }
    }

    return null;
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final user = User.fromJson(userData);

    await prefs.setInt('id', user.id);
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('firstName', user.firstName);
    await prefs.setString('lastName', user.lastName);
    await prefs.setString('gender', user.gender);
    await prefs.setInt('age', user.age);
    await prefs.setString('mobile', user.mobile);
    await prefs.setString('image', user.image);
    await prefs.setString('coverImage', user.coverImage);
    await prefs.setString('accessToken', user.accessToken);
    await prefs.setString('refreshToken', user.refreshToken);

    if (userData.containsKey('token')) {
      await prefs.setString('token', userData['token'] ?? '');
    } else if (user.accessToken.isNotEmpty) {
      await prefs.setString('token', user.accessToken);
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'id': prefs.getInt('id') ?? 0,
      'username': prefs.getString('username') ?? '',
      'email': prefs.getString('email') ?? '',
      'firstName': prefs.getString('firstName') ?? '',
      'lastName': prefs.getString('lastName') ?? '',
      'gender': prefs.getString('gender') ?? '',
      'age': prefs.getInt('age') ?? 0,
      'mobile': prefs.getString('mobile') ?? '',
      'image': prefs.getString('image') ?? '',
      'coverImage': prefs.getString('coverImage') ?? '',
      'accessToken': prefs.getString('accessToken') ?? '',
      'refreshToken': prefs.getString('refreshToken') ?? '',
      'token': prefs.getString('token') ?? prefs.getString('accessToken') ?? '',
    };
  }

  Future<User> getUser() async {
    final userData = await getUserData();
    return User.fromJson(userData);
  }

  // Authors repeat across the feed, notifications and comments; fetch each once.
  static final Map<int, Future<User>> _userCache = {};

  Future<User> getUserById(int userId) {
    final cached = _userCache[userId];
    if (cached != null) return cached;

    final future = _fetchUserById(userId);
    _userCache[userId] = future;
    // Drop failed lookups so they can be retried.
    future.then<void>((_) {}, onError: (_) => _userCache.remove(userId));
    return future;
  }

  Future<User> _fetchUserById(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsers = prefs.getStringList('registered_users') ?? [];

    for (final value in storedUsers) {
      final user = jsonDecode(value) as Map<String, dynamic>;
      if ((user['id'] ?? 0) == userId) {
        return User.fromJson(user);
      }
    }

    final response = await get(Uri.parse('$host/users/$userId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load user');
    }

    return User.fromJson(jsonDecode(response.body));
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in [
        'id',
        'username',
        'email',
        'firstName',
        'lastName',
        'gender',
        'age',
        'mobile',
        'image',
        'coverImage',
        'accessToken',
        'refreshToken',
        'token',
        'is_logged_in',
        'user_email',
        'user_name',
        'user_username',
      ]) {
        await prefs.remove(key);
      }
    } catch (e) {
      throw Exception('Failed to log out: $e');
    }
  }
}
