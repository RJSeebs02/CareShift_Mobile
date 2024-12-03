import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final String nurseId;
  final String initialFirstName;
  final String initialMiddleName;
  final String initialLastName;
  final String initialEmail;
  final String initialContact;

  const EditProfilePage({
    Key? key,
    required this.nurseId,
    required this.initialFirstName,
    required this.initialMiddleName,
    required this.initialLastName,
    required this.initialEmail,
    required this.initialContact,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the initial values
    _firstNameController = TextEditingController(text: widget.initialFirstName);
    _middleNameController = TextEditingController(text: widget.initialMiddleName);
    _lastNameController = TextEditingController(text: widget.initialLastName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _contactController = TextEditingController(text: widget.initialContact);
  }

  // Validate email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Validate contact number format
  String? _validateContact(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your contact number';
    }
    final contactRegExp = RegExp(r'^\+?[1-9]\d{1,14}$'); // Validates international phone numbers
    if (!contactRegExp.hasMatch(value)) {
      return 'Please enter a valid contact number';
    }
    return null;
  }

  Future<void> updateProfile() async {
    final url = 'https://careshift.helioho.st/mobile/serve/nurse/update.php';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nurse_id': widget.nurseId, // Ensure nurseId is part of the body if it's needed
        'nurse_fname': _firstNameController.text,
        'nurse_mname': _middleNameController.text,
        'nurse_lname': _lastNameController.text,
        'nurse_email': _emailController.text,
        'nurse_contact': _contactController.text,
      }),
    );

    // Debugging response status and body
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context); // Go back to the previous page after update
    } else {
      final responseData = jsonDecode(response.body);
      String errorMessage = responseData['message'] ?? 'Failed to update profile. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _middleNameController,
                decoration: const InputDecoration(labelText: 'Middle Name'),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: _validateEmail,
              ),
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: 'Contact'),
                keyboardType: TextInputType.phone,
                validator: _validateContact,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    updateProfile();
                  }
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}