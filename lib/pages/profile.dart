import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        Uri.parse('https://russgarde03.helioho.st/serve/nurse/read.php?nurse_id=$nurseId'),
      );

      if (response.statusCode == 200) {
        // Check if response body is valid JSON
        try {
          final data = jsonDecode(response.body);
          // Check if data is a map (single nurse data)
          if (data is Map<String, dynamic>) {
            setState(() {
              nurseData = data; // Directly assign the nurse data
            });
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
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: nurseData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nurse ID: ${nurseData!['nurse_id']}'),
                  Text('First Name: ${nurseData!['nurse_fname']}'),
                  Text('Middle Name: ${nurseData!['nurse_mname']}'),
                  Text('Last Name: ${nurseData!['nurse_lname']}'),
                  Text('Email: ${nurseData!['nurse_email']}'),
                  Text('Contact: ${nurseData!['nurse_contact']}'),
                  Text('Position: ${nurseData!['nurse_position']}'),
                  Text('Department: ${nurseData!['nurse_department']}'),
                  const SizedBox(height: 20),   
                  QrImageView(
                    data: jsonEncode({'nurse_id': nurseId}),
                    version: QrVersions.auto,    
                    size: 300.0,                
                  ),
                ],
              ),
            ),
    );
  }
}
