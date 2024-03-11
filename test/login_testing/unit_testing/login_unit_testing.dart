import 'package:flutter_test/flutter_test.dart';
import 'package:palmear_application/data/services/auth_services.dart';

void main() {
  // Instance of AuthService
  final authService = AuthService();

  group('AuthService', () {
    test('authenticates successfully with valid credentials', () async {
      expect(await authService.authenticate('example123@gmail.com', '123'),
          isTrue);
    });

    test('authentication fails with invalid credentials', () async {
      expect(
          await authService.authenticate('user@example.com', 'wrongpassword'),
          isFalse);
    });

    test('authentication fails with empty email and password', () async {
      expect(await authService.authenticate('', ''), isFalse);
    });
  });
}
