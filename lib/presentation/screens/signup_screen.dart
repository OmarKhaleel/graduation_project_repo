import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/firebase_services/firebase_auth_services.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/back_arrow.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/email_label.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/email_textfield.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/enter_credentials_text.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/password_label.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/password_textfield.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/top_green_half_circle.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/welcome_to_palmear_text.dart';
import 'package:palmear_application/presentation/widgets/signup_screen_widgets/agree_to_terms_checkbox.dart';
import 'package:palmear_application/presentation/widgets/signup_screen_widgets/error_message_text.dart';
import 'package:palmear_application/presentation/widgets/signup_screen_widgets/signup_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _agreeToTerms = false;

  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setEmail(String value) {
    setState(() {
      _emailController.text = value;
    });
  }

  void _setPassword(String value) {
    setState(() {
      _passwordController.text = value;
    });
  }

  void _setAgreeToTerms(bool? value) {
    setState(() {
      _agreeToTerms = value ?? false;
    });
  }

  void _setErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const TopGreenHalfCircle(),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                AgreeToTermsCheckbox(
                    agreeToTerms: _agreeToTerms, onChanged: _setAgreeToTerms),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                if (_errorMessage.isNotEmpty)
                  ErrorMessageText(errorMessage: _errorMessage),
                SignUpButton(
                  context: context,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  agreeToTerms: _agreeToTerms,
                  auth: _auth,
                  setErrorMessage: _setErrorMessage,
                ),
              ],
            ),
          ),
          const BackArrow(),
        ],
      ),
    );
  }
}
