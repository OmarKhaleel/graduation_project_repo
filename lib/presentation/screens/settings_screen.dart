import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/user_services/user_details.dart';
import 'package:palmear_application/presentation/widgets/settings_screen_widgets/account_label.dart';
import 'package:palmear_application/presentation/widgets/settings_screen_widgets/app_version_label.dart';
import 'package:palmear_application/presentation/widgets/settings_screen_widgets/app_version_list_tile.dart';
import 'package:palmear_application/presentation/widgets/settings_screen_widgets/cache_test_label.dart';
import 'package:palmear_application/presentation/widgets/settings_screen_widgets/edit_name_textfield_list_tile.dart';
import 'package:palmear_application/presentation/widgets/settings_screen_widgets/logout_list_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userName = '';
  final UserDetails _userDetails = UserDetails();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initUserName();
  }

  Future<void> _initUserName() async {
    String name = await _userDetails.fetchUserName();
    setState(() {
      _nameController.text = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EE),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            const AppVersionLabel(),
            const AppVersionListTile(),
            const AccountLabel(),
            const LogoutListTile(),
            const CacheTestLabel(),
            EditNameTextFieldListTile(
              nameController: _nameController,
              userDetails: _userDetails,
            ),
          ],
        ).toList(),
      ),
    );
  }
}
