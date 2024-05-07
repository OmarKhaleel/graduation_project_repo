import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:palmear_application/presentation/screens/signin_screen.dart';
import 'package:palmear_application/presentation/widgets/toast.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EE),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 28.0, bottom: 8.0),
              child: Text(
                "ACCOUNT",
                style: TextStyle(
                    color: Color(0xFFB0AFB0), fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              trailing: const Icon(Icons.logout),
              tileColor: Colors.white,
              title: const Text('Logout'),
              textColor: Colors.red,
              iconColor: Colors.red,
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignInScreen()));
                showToast(message: "Successfully signed out");
              },
            ),
          ],
        ).toList(),
      ),
    );
  }
}
