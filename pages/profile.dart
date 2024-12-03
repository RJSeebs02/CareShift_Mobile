import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile.dart';
import 'edit_password.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final String nurseId;

  const ProfilePage({Key? key, required this.nurseId}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? nurseData;
  String nurseId = '';

  @override
  void initState() {
    super.initState();
    _loadNurseId();
  }

  Future<void> _loadNurseId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nurseId = prefs.getString('nurse_id') ?? '';
    });

    if (nurseId.isNotEmpty) {
      fetchNurseData(nurseId);
    } else {
      print("No nurseId found in SharedPreferences");
    }
  }

  Future<void> fetchNurseData(String nurseId) async {
    try {
      final response = await http.get(
        Uri.parse('https://careshift.helioho.st/mobile/serve/nurse/read.php?nurse_id=$nurseId'),
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data is Map<String, dynamic>) {
            if (mounted) {
              setState(() {
                nurseData = data;
              });
            }
          } else {
            print('Unexpected data format: $data');
          }
        } catch (e) {
          print('Failed to parse JSON: $e');
          print('Response body: ${response.body}');
        }
      } else {
        print('Failed to load nurse data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching nurse data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: nurseData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Nurse ID: ${nurseData!['nurse_id']}'),
                  Text('First Name: ${nurseData!['nurse_fname']}'),
                  Text('Middle Name: ${nurseData!['nurse_mname']}'),
                  Text('Last Name: ${nurseData!['nurse_lname']}'),
                  Text('Email: ${nurseData!['nurse_email']}'),
                  Text('Contact: ${nurseData!['nurse_contact']}'),
                  Text('Position: ${nurseData!['nurse_position']}'),
                  Text('Department: ${nurseData!['department_name']}'),
                  // Position and Department are removed for the updated version
                  const SizedBox(height: 20),

                  // Edit Profile Button
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the Edit Profile page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(
                            nurseId: widget.nurseId,
                            initialFirstName: nurseData!['nurse_fname'],
                            initialMiddleName: nurseData!['nurse_mname'],
                            initialLastName: nurseData!['nurse_lname'],
                            initialEmail: nurseData!['nurse_email'],
                            initialContact: nurseData!['nurse_contact'].toString(),
                          ),
                        ),
                      );
                    },
                    child: const Text('Edit Profile'),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the Edit Password page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPasswordPage(nurseId: widget.nurseId),
                        ),
                      );
                    },
                    child: const Text('Edit Password'),
                  ),
                  QrImageView(
                    data: jsonEncode(int.parse(nurseId)),
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ],
              ),
            ),
    );
  }
}