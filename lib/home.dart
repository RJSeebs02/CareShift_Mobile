import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careshift/pages/schedule.dart';
import 'package:careshift/pages/leave.dart';
import 'package:careshift/pages/notifications.dart';
import 'package:careshift/pages/profile.dart';
import 'colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String firstName = '';
  String lastName = '';
  String email = '';
  String contactNo = '';
  String position = '';
  String department = '';
  String nurseId = '';
  Future<List<Widget>>? _pages; // Declare _pages as a nullable Future variable

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    nurseId = prefs.getString('nurse_id') ?? ''; // Get the nurseId

    // Debugging log
    print('Fetched nurseId: $nurseId'); // Log the fetched nurseId

    if (nurseId.isNotEmpty) {
      // Initialize pages after nurseId is fetched
      setState(() {
        _pages = _initializePages();
      });
    } else {
      print("No nurseId found in SharedPreferences."); // Log if nurseId is null or empty
    }
  }

  Future<List<Widget>> _initializePages() async {
    return <Widget>[
      SchedulePage(),
      LeavePage(nurseId: nurseId), // Pass the nurseId to LeavePage
      NotificationPage(),
      ProfilePage(nurseId: nurseId), // Pass the nurseId to ProfilePage
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('validation');
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CareShift',
          style: TextStyle(color: AppColors.mainLightColor),
        ),
        backgroundColor: AppColors.mainDarkColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.mainLightColor),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Widget>>(
        future: _pages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return snapshot.data![_selectedIndex]; // Return the selected page
          } else {
            return Center(child: Text('No pages available.')); // Display a message if no pages are available
          }
        },
      ),
      bottomNavigationBar: Container(
        height: 80.0,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
            BottomNavigationBarItem(icon: Icon(Icons.insert_drive_file), label: 'Leave'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
          backgroundColor: AppColors.mainDarkColor,
          unselectedItemColor: AppColors.mainLightColor,
          selectedItemColor: AppColors.mainColor,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}