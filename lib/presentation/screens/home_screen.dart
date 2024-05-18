import 'package:flutter/material.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/bottom_navigation_bar.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/build_page_content.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pest Detection',
              style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF00916E),
          automaticallyImplyLeading: false,
        ),
        backgroundColor: const Color(0xFF00916E),
        body: buildPageContent(context, _selectedIndex),
        bottomNavigationBar: BottomNavigationBarScreen(
          selectedIndex: _selectedIndex,
          onItemSelected: _onItemTapped,
        ));
  }
}
