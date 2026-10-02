import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:turno_advmobprog_longexam/services/auth_service.dart';
import 'package:turno_advmobprog_longexam/services/user_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('saveSession stores user state and isLoggedIn reports true', () async {
    final authService = AuthService();

    await authService.saveSession(
      email: 'test@example.com',
      name: 'Test User',
      username: '@testuser',
    );

    expect(await authService.isLoggedIn(), isTrue);
    expect(await authService.getUserName(), 'Test User');
  });

  test(
    'demo credentials login succeeds with the DummyJSON example account',
    () async {
      final authService = AuthService();

      final result = await authService.login(
        email: 'kminchelle',
        password: '0lelplR',
      );

      expect(result, isTrue);
      expect(await authService.isLoggedIn(), isTrue);
    },
  );

  test('fallback login succeeds for any non-empty credentials', () async {
    final authService = AuthService();

    final result = await authService.login(
      email: 'student@example.com',
      password: 'student123',
    );

    expect(result, isTrue);
    expect(await authService.isLoggedIn(), isTrue);
  });

  test('clearSession removes persisted login state', () async {
    final authService = AuthService();

    await authService.saveSession(
      email: 'test@example.com',
      name: 'Test User',
      username: '@testuser',
    );
    await authService.clearSession();

    expect(await authService.isLoggedIn(), isFalse);
  });

  test('local user signup is accepted and can log in later', () async {
    final userService = UserService();

    await userService.registerUser(
      firstName: 'Turno',
      lastName: 'User',
      username: 'turnouser',
      password: 'Password1!',
      email: 'turnouser@example.com',
      mobile: '09123456789',
      age: 21,
      gender: 'Male',
    );

    final userData = await userService.loginUser('turnouser', 'Password1!');

    expect(userData['username'], 'turnouser');
    expect(userData['firstName'], 'Turno');
    expect(userData['age'], 21);
    expect(userData['mobile'], '09123456789');
    expect(userData['email'], 'turnouser@example.com');

    final byEmail = await userService.loginUser(
      'TurnoUser@Example.com',
      'Password1!',
    );
    expect(byEmail['username'], 'turnouser');
  });
}
