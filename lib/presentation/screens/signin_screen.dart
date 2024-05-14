import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/firebase_services/firebase_auth_services.dart';
import 'package:palmear_application/data/services/firestore_services/sync_manager.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/email_label.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/email_textfield.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/enter_credentials_text.dart';
import 'package:palmear_application/presentation/widgets/signin_screen_widgets/forgot_password_text.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/password_label.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/password_textfield.dart';
import 'package:palmear_application/presentation/widgets/signin_screen_widgets/signin_button.dart';
import 'package:palmear_application/presentation/widgets/signin_screen_widgets/signup_text.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/top_green_half_circle.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/welcome_to_palmear_text.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final SyncManager _syncManager = SyncManager();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _setEmail(String value) {
    if (mounted) {
      setState(() {
        _emailController.text = value;
      });
    }
  }

  void _setPassword(String value) {
    if (mounted) {
      setState(() {
        _passwordController.text = value;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const TopGreenHalfCircle(),
          SingleChildScrollView(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                const WelcomeToPalmearText(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                const EnterCredentialsText(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                const EmailLabel(),
                const SizedBox(height: 5.0),
                EmailTextField(
                  controller: _emailController,
                  onChanged: _setEmail,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                const PasswordLabel(),
                const SizedBox(height: 5.0),
                PasswordTextField(
                  controller: _passwordController,
                  onChanged: _setPassword,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                const ForgotPasswordText(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                SignInButton(
                  context: context,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  auth: _auth,
                  syncManager: _syncManager,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.005),
                const SignupText(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
