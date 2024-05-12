import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/bottom_navigation_bar.dart';

void main() {
  testWidgets('Bottom Navigation Bar Test - Check Selected Tab Color',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomNavigationBarScreen(
            selectedIndex: 0, // Assuming 'Home' is initially selected
            onItemSelected: (index) {},
          ),
        ),
      ),
    );

    // Verify that the bottom navigation bar is present on the screen
    final bottomNavigationBarFinder = find.byType(BottomNavigationBar);
    expect(bottomNavigationBarFinder, findsOneWidget);

    // Retrieve the BottomNavigationBar widget from the widget tester
    final bottomNavigationBar =
        tester.widget<BottomNavigationBar>(bottomNavigationBarFinder);

    // Get the selected tab's background color
    final selectedItemColor = bottomNavigationBar.selectedItemColor;

    // Check if the selected tab's color matches the expected color
    expect(selectedItemColor,
        const Color(0xFF00916E)); // Use the default color for selected tabs
  });
}
