import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palmear_application/presentation/screens/home_screen.dart';

void main() {
  group('Home Screen Tests', () {
    testWidgets(
      'Test button behavior and countdown with "palmear" audio device connected',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MyHomePage(),
          ),
        );

        // Pump to ensure all async operations are settled.
        await tester.pumpAndSettle();

        expect(find.textContaining('Palmear Audio Amplifier Status: Connected'),
            findsOneWidget);

        final Finder elevatedButtonFinder = find.byType(ElevatedButton);
        await tester.tap(elevatedButtonFinder);
        await tester.pumpAndSettle();

        final ElevatedButton button =
            tester.widget(elevatedButtonFinder) as ElevatedButton;
        expect(button.style!.backgroundColor!.resolve({MaterialState.pressed}),
            equals(Colors.red));
        expect(find.text('Press to stop listening'), findsOneWidget);

        expect(find.text('Listening time: 50 seconds'), findsOneWidget);
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Listening time: 49 seconds'), findsOneWidget);

        await tester.tap(elevatedButtonFinder);
        await tester.pumpAndSettle();
        expect(find.text('Listening time: 50 seconds'), findsOneWidget);
        expect(find.text('Press to start listening'), findsOneWidget);
      },
    );
  });
}
