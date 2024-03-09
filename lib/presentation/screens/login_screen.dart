import 'package:flutter/material.dart';
import 'package:palmear_application/data/repositories/audio_device_repository_impl.dart';
import 'package:palmear_application/domain/use_cases/get_audio_devices.dart';
import 'package:palmear_application/presentation/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String email;
  late String password;
  bool agreeToTerms = false;
  late GetAudioDevices getAudioDevices;

  @override
  void initState() {
    super.initState();
    email = '';
    password = '';
    final audioDeviceRepository = AudioDeviceRepositoryImpl();
    getAudioDevices = GetAudioDevices(audioDeviceRepository);
  }

  void setEmail(String value) {
    setState(() {
      email = value;
    });
  }

  void setPassword(String value) {
    setState(() {
      password = value;
    });
  }

  void setAgreeToTerms(bool? value) {
    setState(() {
      agreeToTerms = value ?? false;
    });
  }

  Color getButtonColor() {
    if (email.isNotEmpty && password.isNotEmpty && agreeToTerms) {
      return const Color(0xFF00916E);
    } else {
      return const Color(0xFF66BEA8);
    }
  }

  void login() {
    if (email.isNotEmpty && password.isNotEmpty && agreeToTerms) {
      if (email == 'example123@gmail.com' && password == '123') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(getAudioDevices: getAudioDevices),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sign In Error'),
              content: const Text('Invalid email or password'),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Welcome to Palmear',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 100),
                const Text(
                  'Please enter your credentials',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      key: const Key('email_field'),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF00916E)),
                        ),
                        hintText: 'Enter your email',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: setEmail,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      key: const Key('password_field'),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF00916E)),
                        ),
                        hintText: 'Enter your password',
                      ),
                      obscureText: true,
                      onChanged: setPassword,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // Implement forgot password here
                  },
                  child: const Text(
                    'Forgot Password?',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: login,
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
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
