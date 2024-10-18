import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:careshift/pages/schedule.dart';
import 'package:careshift/pages/leave.dart';
import 'package:careshift/pages/notifications.dart';
import 'package:careshift/pages/profile.dart';
import 'colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    SchedulePage(),
    LeavePage(),
    NotificationPage(),
    ProfilePage(),
  ];

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
            icon: const Icon(
              Icons.logout,
              color: AppColors.mainLightColor),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 80.0,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_drive_file),
              label: 'Leave',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
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
