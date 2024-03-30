import 'package:flutter/material.dart';
import 'package:palmear_application/data/repositories/audio_device_repository_impl.dart';
import 'package:palmear_application/data/services/firebase_auth_services.dart';
import 'package:palmear_application/domain/use_cases/get_audio_devices.dart';
import 'package:palmear_application/presentation/screens/home_screen.dart';
import 'package:palmear_application/presentation/screens/signup_screen.dart';
import 'package:palmear_application/presentation/widgets/toast.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late GetAudioDevices getAudioDevices;

  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final audioDeviceRepository = AudioDeviceRepositoryImpl();
    getAudioDevices = GetAudioDevices(audioDeviceRepository);
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

  Color getButtonColor() {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
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
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                Text(
                  'Welcome to Palmear',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Text(
                  'Please enter your credentials',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.03,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Email',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.03,
                          fontWeight: FontWeight.bold),
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
                    Text(
                      'Password',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.03,
                          fontWeight: FontWeight.bold),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                GestureDetector(
                  onTap: () {
                    // Implement forgot password here
                  },
                  child: Text(
                    'Forgot Password?',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: MediaQuery.of(context).size.width * 0.025,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                ElevatedButton(
                  onPressed: _signIn,
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
                  child: const Text('Sign In'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpScreen()),
                    );
                  },
                  child: Text(
                    'Don\'t have an account? Sign up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: MediaQuery.of(context).size.width * 0.03,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _signIn() {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      _auth.signInWithEmailAndPassword(email, password);

      try {
        showToast(message: "User is successfully signed in!");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MyHomePage(getAudioDevices: getAudioDevices)),
        );
      } catch (e) {
        showToast(message: "Error signing in: $e");
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign In Error'),
            content: const Text('Empty email or password'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
