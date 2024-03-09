import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palmear_application/presentation/widgets/bottom_navigation_bar.dart';

void main() {
  testWidgets('Bottom Navigation Bar Test', (WidgetTester tester) async {
    // Build the bottom navigation bar widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomNavigationBarScreen(
            selectedIndex: 0,
            onItemSelected: (index) {},
          ),
        ),
      ),
    );

    // Verify that the bottom navigation bar contains three items
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.map), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);

    // Tap on the second navigation item (index 1)
    await tester.tap(find.byIcon(Icons.map));
    await tester.pump();

    // Verify that the second navigation item is selected
    expect(find.text('Home'), findsNothing);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Settings'), findsNothing);

    // Tap on the third navigation item (index 2)
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();

    // Verify that the third navigation item is selected
    expect(find.text('Home'), findsNothing);
    expect(find.text('Map'), findsNothing);
    expect(find.text('Settings'), findsOneWidget);
  });
}
