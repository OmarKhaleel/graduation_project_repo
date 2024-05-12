import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/firebase_services/signout_service.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';

class LogoutListTile extends StatelessWidget {
  const LogoutListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: const Icon(Icons.logout),
      tileColor: Colors.white,
      title: const Text('Logout'),
      textColor: Colors.red,
      iconColor: Colors.red,
      onTap: () {
        signOut(context).then((_) {
          showToast(message: "Successfully signed out");
        });
      },
    );
  }
}
