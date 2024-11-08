import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cpasswordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  
  String errorMessage = '';

  Future<void> _signup() async {
  final String nurse_email = emailController.text.trim();
  final String nurse_password = passwordController.text.trim();
  final String nurse_cpassword = cpasswordController.text.trim();
  final String nurse_fname = firstNameController.text.trim();
  final String nurse_mname = middleNameController.text.trim();
  final String nurse_lname = lastNameController.text.trim();
  final String nurse_sex = sexController.text.trim();
  final String nurse_contact = contactController.text.trim();
  final String nurse_position = positionController.text.trim();
  final String nurse_department = departmentController.text.trim();

  if (nurse_email.isEmpty || nurse_password.isEmpty || nurse_cpassword.isEmpty ||
      nurse_fname.isEmpty || nurse_lname.isEmpty || nurse_sex.isEmpty ||
      nurse_contact.isEmpty || nurse_position.isEmpty || nurse_department.isEmpty) {
    setState(() {
      errorMessage = 'Please fill in all fields!';
    });
    return;
  }

  if (nurse_password != nurse_cpassword) {
    setState(() {
      errorMessage = 'Passwords do not match!';
    });
    return;
  }

  const String apiUrl = 'https://russgarde03.helioho.st/serve/nurse/create.php';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode({
        'nurse_email': nurse_email,
        'nurse_password': nurse_password,
        'nurse_fname': nurse_fname,
        'nurse_mname': nurse_mname,
        'nurse_lname': nurse_lname,
        'nurse_sex': nurse_sex,
        'nurse_contact': nurse_contact,
        'nurse_position': nurse_position,
        'nurse_department': nurse_department,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    // Log response for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final bool success = responseData['message'] == "Account was created.";

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('registered', success);

      if (success) {
        _navigateToLogin();
      } else {
        setState(() {
          errorMessage = 'Failed to register. Please try again.';
        });
      }
    } else if (response.statusCode == 400) {
      final responseData = jsonDecode(response.body);
      setState(() {
        errorMessage = responseData['message']; // Display specific error message from server
      });
    } else if (response.statusCode == 503) {
      setState(() {
        errorMessage = 'Email already exists!';
      });
    } else {
      setState(() {
        errorMessage = 'An unexpected error occurred. Please try again.';
      });
    }
  } catch (e) {
    setState(() {
      errorMessage = 'Error: $e';
    });
  }
}

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                _buildTitle(),
                _buildRegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'CareShift',
      style: TextStyle(
        color: Colors.black,
        fontSize: 64,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          TextField(
            controller: firstNameController,
            decoration: _inputDecoration('First Name'),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: middleNameController,
            decoration: _inputDecoration('Middle Name'),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: lastNameController,
            decoration: _inputDecoration('Last Name'),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: sexController,
            decoration: _inputDecoration('Sex'),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: contactController,
            decoration: _inputDecoration('Contact Number'),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: emailController,
            decoration: _inputDecoration('Email'),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: passwordController,
            decoration: _inputDecoration('Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: cpasswordController,
            decoration: _inputDecoration('Confirm Password'),
            obscureText: true,
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: positionController,
            decoration: _inputDecoration('Position'),
          ),
          const SizedBox(height: 20.0),
          TextField(
            controller: departmentController,
            decoration: _inputDecoration('Department'),
          ),
          const SizedBox(height: 20.0),
          Text(errorMessage, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 20.0),
          _buildSignupButton(),
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

  Widget _buildSignupButton() {
    return GestureDetector(
      onTap: _signup,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        decoration: BoxDecoration(
          color: const Color(0xFF29CE7A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Sign Up',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}