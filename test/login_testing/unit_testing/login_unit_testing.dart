import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:palmear_application/presentation/screens/home_screen.dart';
import 'package:palmear_application/presentation/screens/login_screen.dart';

class MockLoginScreen extends Mock implements LoginScreen {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return '';
  }
}

void main() {
  late MockLoginScreen loginScreen;

  setUp(() {
    loginScreen = MockLoginScreen();
  });

  testWidgets('Valid Credential Test Case', (WidgetTester tester) async {
    await tester.pumpWidget(loginScreen);

    // valid credential
    await tester.enterText(
        find.byKey(const Key('email_field')), 'example123@gmail.com');
    await tester.enterText(find.byKey(const Key('password_field')), '123');

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('Invalid Credential Test Case', (WidgetTester tester) async {
    await tester.pumpWidget(loginScreen);

    // invalid credentials
    await tester.enterText(
        find.byKey(const Key('email_field')), 'invalid@example.com');
    await tester.enterText(
        find.byKey(const Key('password_field')), 'invalidpassword');

    await tester.tap(find.text('Login'));
    await tester.pump();

    // Verify that error message is shown
    expect(find.text('Invalid email or password'), findsOneWidget);
  });

  testWidgets('Empty Email/Password Fields Test Case',
      (WidgetTester tester) async {
    await tester.pumpWidget(loginScreen);

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.byType(MyHomePage), findsNothing);
    expect(find.text('Invalid email or password'), findsNothing);
  });
}
