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
  List<Map<String, String>> departments = []; // Storing department name and id pair
  String? selectedDepartmentId;

  Future<void> fetchDepartments() async {
    const String apiUrl = 'https://careshift.helioho.st/departments-module/fetch_departments.php';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<Map<String, String>> fetchedDepartments = (responseData['records'] as List)
            .map((record) => {
                  'department_name': record['department_name'] as String,
                  'department_id': record['department_id'] as String
                })
            .toList();

        setState(() {
          departments = fetchedDepartments;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch departments. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
      });
    }
  }

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

    if (nurse_email.isEmpty || nurse_password.isEmpty || nurse_cpassword.isEmpty ||
        nurse_fname.isEmpty || nurse_lname.isEmpty || nurse_sex.isEmpty ||
        nurse_contact.isEmpty || nurse_position.isEmpty || selectedDepartmentId == null) {
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

    const String apiUrl = 'https://careshift.helioho.st/mobile/serve/nurse/create.php';

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
          'department_id': selectedDepartmentId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

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
          errorMessage = responseData['message']; 
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
  void initState() {
    super.initState();
    fetchDepartments();
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
                buildSignupButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min, 
      children: [
        Image.asset(
          '../assets/logo.png', 
          height: 64, 
          width: double.infinity, 
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8), 
        const Text(
          'REGISTER', 
          style: TextStyle(
            color: Colors.black,
            fontSize: 24, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: firstNameController,
                  decoration: _inputDecoration('First Name'),
                ),
              ),
              const SizedBox(width: 10.0),  
              Expanded(
                child: TextField(
                  controller: middleNameController,
                  decoration: _inputDecoration('Middle Name'),
                ),
              ),
              const SizedBox(width: 10.0),  
              Expanded(
                child: TextField(
                  controller: lastNameController,
                  decoration: _inputDecoration('Last Name'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: sexController.text.isNotEmpty ? sexController.text : null,
                  decoration: _inputDecoration('Sex'),
                  items: ['Male', 'Female'].map((String sex) {
                    return DropdownMenuItem<String>(value: sex, child: Text(sex));
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      sexController.text = newValue;
                    }
                  },
                ),
              ),
              const SizedBox(width: 10.0),  
              Expanded(
                child: TextField(
                  controller: contactController,
                  decoration: _inputDecoration('Contact Number'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20.0),
          TextField(
            controller: emailController,
            decoration: _inputDecoration('Email'),
          ),
          const SizedBox(height: 20.0),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: passwordController,
                  decoration: _inputDecoration('Password'),
                  obscureText: true,
                ),
              ),
              const SizedBox(width: 10.0),  
              Expanded(
                child: TextField(
                  controller: cpasswordController,
                  decoration: _inputDecoration('Confirm Password'),
                  obscureText: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20.0),
          DropdownButtonFormField<String>(
            value: positionController.text.isNotEmpty ? positionController.text : null,
            decoration: _inputDecoration('Position'),
            items: [
              DropdownMenuItem<String>(value: "", child: Text("Select Position")),
              DropdownMenuItem<String>(value: "Nurse I", child: Text("Nurse I")),
              DropdownMenuItem<String>(value: "Nurse II", child: Text("Nurse II")),
              DropdownMenuItem<String>(value: "Nurse III", child: Text("Nurse III")),
              DropdownMenuItem<String>(value: "Nurse IV", child: Text("Nurse IV")),
              DropdownMenuItem<String>(value: "Nurse V", child: Text("Nurse V")),
              DropdownMenuItem<String>(value: "Nursing Attendant I", child: Text("Nursing Attendant I")),
              DropdownMenuItem<String>(value: "Nursing Attendant II", child: Text("Nursing Attendant II")),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                positionController.text = newValue;
              }
            },
          ),

          const SizedBox(height: 20.0),
          DropdownButtonFormField<String>(
            value: selectedDepartmentId,
            decoration: _inputDecoration('Department'),
            items: departments
                .map((department) => DropdownMenuItem<String>(
                      value: department['department_id'],
                      child: Text(department['department_name']!),
                    ))
                .toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedDepartmentId = newValue;
              });
            },
          ),

          const SizedBox(height: 20.0),
          Text(
            errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget buildSignupButton() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Color(0xFF7BB9FA),
        ),
        onPressed: _signup,
        child: const Text(
          'Sign Up',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.all(15.0),
    );
  }
}