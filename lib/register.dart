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
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();
  String errorMessage = '';

  Future<void> _signup() async {
    final String user_username = usernameController.text.trim();
    final String user_password = passwordController.text.trim();
    final String user_cpassword = cpasswordController.text.trim();

    if (user_password != user_cpassword) {
      setState(() {
        errorMessage = 'Passwords do not match!';
      });
      return;
    }

    // Your API endpoint for registration
    const String apiUrl = 'https://zenenix.helioho.st/serve/user/create.php';
    const String apiUrlCart = 'https://zenenix.helioho.st/serve/carting/cartcreate.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({'user_username': user_username, 'user_password': user_password}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        // Successful registration
          try {
            final response = await http.post(
            Uri.parse(apiUrlCart),
            body: jsonEncode({'user_username': user_username}),
            headers: {'Content-Type': 'application/json'},
          );
          } catch (e) {
            // Handle network errors
            setState(() {
              errorMessage = 'Error huhu: $e';
            });
          }
        final responseData = jsonDecode(response.body);
        final bool success = responseData['message'] == "User was created.";

        // Store registration status in shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('registered', success);

        if (success) {
          _navigateToLogin();
        } else {
          setState(() {
            errorMessage = 'Failed to register.';
          });
        }
      } else if (response.statusCode == 503) {
        // Username already exists
        setState(() {
          errorMessage = 'Username already exists!';
        });
      } else {
        // Handle other errors
        setState(() {
          errorMessage = 'Please Fill in the Required Fields!';
        });
      }
    } catch (e) {
      // Handle network errors
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
                const SizedBox(height: 25),

                Text(
                  'Create an Account',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 32,
                  ),
                ),

                const SizedBox(height: 40),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      cursorColor: Colors.black,
                      controller: usernameController,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 212, 208, 208)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Username',
                      ),
                    ),

                    const SizedBox(height: 25),

                    TextField(
                      cursorColor: Colors.black,
                      controller: passwordController,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 212, 208, 208)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Password',
                      ),
                      obscureText: true,
                    ),

                    const SizedBox(height: 20.0),

                    TextField(
                      cursorColor: Colors.black,
                      controller: cpasswordController,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 212, 208, 208)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Confirm Password',
                      ),
                      obscureText: true,
                    ),

                    const SizedBox(height: 20.0),

                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20.0),

                    GestureDetector(
                      onTap: _signup,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        decoration: BoxDecoration(
                          color: const Color(0xFF393742),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60.0),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
