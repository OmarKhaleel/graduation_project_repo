import 'package:flutter/material.dart';
import 'package:palmear_application/presentation/widgets/forgot_password_screen_widgets/enter_your_email_text.dart';
import 'package:palmear_application/presentation/widgets/forgot_password_screen_widgets/reset_password_button.dart';
import 'package:palmear_application/presentation/widgets/forgot_password_screen_widgets/reset_password_text.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/back_arrow.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/email_label.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/email_textfield.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/top_green_half_circle.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _setEmail(String value) {
    setState(() {
      _emailController.text = value;
    });
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
                const ResetPasswordText(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                const EnterYourEmailText(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                const EmailLabel(),
                const SizedBox(height: 5.0),
                EmailTextField(
                  controller: _emailController,
                  onChanged: _setEmail,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                ResetPasswordButton(emailController: _emailController),
              ],
            ),
          ),
          const BackArrow(),
        ],
      ),
    );
  }
}
