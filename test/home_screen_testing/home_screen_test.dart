import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'home_screen_widgets.dart';

void main() {
  group('Home Screen Tests', () {
    testWidgets(
      'Test button behavior and countdown with "palmear" audio device connected',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: MyHomePageTest(),
          ),
        );

        // Pump to ensure all async operations are settled.
        await tester.pumpAndSettle();

        // expect(find.textContaining('Palmear Audio Amplifier Status: Connected'),
        //     findsOneWidget);

        final Finder elevatedButtonFinder = find.byType(ElevatedButton);
        await tester.tap(elevatedButtonFinder);
        await tester.pumpAndSettle();

        // Check the color of the icon inside the button
        final Finder iconFinder = find.descendant(
          of: elevatedButtonFinder,
          matching: find.byType(Icon),
        );

        Icon icon = tester.widget(iconFinder) as Icon;
        expect(icon.color, equals(Colors.white));

        expect(find.text('Press to stop listening'), findsOneWidget);
        expect(find.text('Listening time: 50 seconds'), findsOneWidget);

        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Listening time: 49 seconds'), findsOneWidget);

        await tester.tap(elevatedButtonFinder);
        await tester.pumpAndSettle();

        icon = tester.widget(iconFinder) as Icon;
        expect(icon.color, equals(const Color(0xFF00916E)));

        expect(find.text('Listening time: 50 seconds'), findsOneWidget);
        expect(find.text('Press to start listening'), findsOneWidget);
      },
    );
  });
}
