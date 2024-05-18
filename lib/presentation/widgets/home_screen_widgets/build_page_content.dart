import 'package:flutter/material.dart';
import 'package:palmear_application/presentation/screens/map_screen.dart';
import 'package:palmear_application/presentation/screens/settings_screen.dart';
import 'package:palmear_application/presentation/widgets/home_screen_widgets/home_body_content.dart';

Widget buildPageContent(BuildContext context, int selectedIndex) {
  switch (selectedIndex) {
    case 0:
      return const HomeBodyContent();
    case 1:
      return const MapScreen();
    case 2:
      return const SettingsScreen();
    default:
      return const HomeBodyContent();
  }
}
