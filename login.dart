import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';
import 'register.dart';
import 'colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> _login() async {
  final String email = emailController.text.trim();
  final String password = passwordController.text.trim();
  const String apiUrl = 'https://careshift.helioho.st/mobile/serve/nurse/validate.php';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({'nurse_email': email, 'nurse_password': password}),
      headers: {'Content-Type': 'application/json'},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); // Log the response body

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');
      final bool validation = responseData['validation'];

      if (validation) {
        String? nurseId = responseData['nurse_id'];
        if (nurseId != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('nurse_id', nurseId);
          print('Nurse ID saved: $nurseId');
          _navigateToHome();
        } else {
          setState(() {
            errorMessage = 'Nurse ID not found.';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Cannot verify account.';
        });
      }
    } else {
      _handleErrorResponse(response);
    }
  } catch (e) {
    setState(() {
      errorMessage = 'Error: $e';
    });
  }
}

  void _handleErrorResponse(http.Response response) {
    switch (response.statusCode) {
      case 400:
        setState(() {
          errorMessage = 'Invalid input. Please check your credentials.';
        });
        break;
      case 401:
        setState(() {
          errorMessage = 'Unauthorized. Check your email and password.';
        });
        break;
      default:
        setState(() {
          errorMessage = 'An unexpected error occurred. Please try again later.';
        });
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.mainLightColor,
    body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Image.asset(
                'assets/logo.png', 
                height: 100,         
                width: 100,          
              ),
              _buildTitle(),
              _buildSubtitle(),
              _buildLoginForm(),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildTitle() {
    return Text(
      'CareShift',
      style: TextStyle(
        color: Colors.black,
        fontSize: 64,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'A CLMMRH Nurse Scheduling Application',
      style: TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            cursorColor: AppColors.mainDarkColor,
            controller: emailController,
            decoration: _inputDecoration('Email'),
          ),
          const SizedBox(height: 25),
          TextField(
            cursorColor: AppColors.mainDarkColor,
            controller: passwordController,
            decoration: _inputDecoration('Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20.0),
          Text(errorMessage, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 20.0),
          _buildLoginButton(),
          const SizedBox(height: 60.0),
          _buildSignUpLink(),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: const Color.fromARGB(255, 212, 208, 208)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
      ),
      fillColor: Colors.white,
      filled: true,
      hintText: hintText,
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _login,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        decoration: BoxDecoration(
          color: const Color(0xFF7BB9FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Login',
          style: TextStyle(color: Color(0xFF181A1D), fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    TextStyle linkStyle = const TextStyle(color: Colors.blue);
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          const TextSpan(text: 'Don\'t have an account yet? ', style: TextStyle(color: Colors.black)),
          TextSpan(
            text: 'Sign Up',
            style: linkStyle,
            recognizer: TapGestureRecognizer()..onTap = () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
            },
          ),
        ],
      ),
    );
  }
}