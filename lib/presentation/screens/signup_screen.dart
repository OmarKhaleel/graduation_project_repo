import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/firebase_services/firebase_auth_services.dart';
import 'package:palmear_application/data/services/firebase_services/signup_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool agreeToTerms = false;

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

  void setEmail(String value) {
    setState(() {
      _emailController.text = value;
    });
  }

  void setPassword(String value) {
    setState(() {
      _passwordController.text = value;
    });
  }

  void setAgreeToTerms(bool? value) {
    setState(() {
      agreeToTerms = value ?? false;
    });
  }

  void setErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  Color getButtonColor() {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        agreeToTerms) {
      return const Color(0xFF00916E);
    } else {
      return const Color(0xFF66BEA8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -MediaQuery.of(context).size.width * 1.1,
            left: -MediaQuery.of(context).size.width * 0.5,
            child: Container(
              width: MediaQuery.of(context).size.width * 2,
              height: MediaQuery.of(context).size.width * 1.5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00916E),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                const Text(
                  'Welcome to Palmear',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                const Text(
                  'Please enter your credentials',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(
                          fontSize: 13.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5.0),
                    TextFormField(
                      key: const Key('email_field'),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF00916E)),
                        ),
                        hintText: 'Enter your email',
                      ),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: setEmail,
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Password',
                      style: TextStyle(
                          fontSize: 13.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5.0),
                    TextFormField(
                      key: const Key('password_field'),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF00916E)),
                        ),
                        hintText: 'Enter your password',
                      ),
                      controller: _passwordController,
                      obscureText: true,
                      onChanged: setPassword,
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Row(
                  children: [
                    Checkbox(
                      value: agreeToTerms,
                      onChanged: setAgreeToTerms,
                    ),
                    GestureDetector(
                      onTap: () {
                        // Implement Privacy Policy and Terms & Conditions here
                      },
                      child: const Text(
                        'I agree to the Privacy policy and Terms & conditions',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(_errorMessage,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14)), // Display the error message
                  ),
                ElevatedButton(
                  onPressed: () {
                    signUp(
                        context,
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        agreeToTerms,
                        _auth,
                        setErrorMessage);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      getButtonColor(),
                    ),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
