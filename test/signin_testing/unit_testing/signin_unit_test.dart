import 'package:flutter_test/flutter_test.dart';
import 'package:palmear_application/data/services/fake_firebase_auth_services.dart';

void main() {
  late FakeAuthService authService;

  setUp(() {
    authService = FakeAuthService();
    authService.signUpWithEmailAndPassword("fares@gmail.com", "1234");
  });

  test('Successful sign-in with correct credentials', () async {
    bool result =
        await authService.signInWithEmailAndPassword("fares@gmail.com", "1234");
    expect(result, isTrue); // Expect a successful sign-in
  });

  test('Successful sign-up with valid email', () async {
    bool result = await authService.signUpWithEmailAndPassword(
        "newuser@example.com", "password123");
    expect(result, isTrue); // Expect a successful sign-up
  });
}
