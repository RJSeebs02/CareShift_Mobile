import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profile_pic.jpg'), // Replace with a path to your image asset
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Text(
                  'Romeo V. Seva',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              buildProfileField('First Name', 'Romeo'),
              buildProfileField('Middle Name', 'Valderama'),
              buildProfileField('Last Name', 'Seva'),
              buildProfileField('Sex', 'Male'),
              buildProfileField('Email', 'rom123@gmail.com'),
              buildProfileField('Position', 'Nurse III'),
              buildProfileField('Contact No', '09562184293'),
              buildProfileField('Department', 'OR'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
