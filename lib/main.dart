import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? validation = prefs.getBool('validation');

  runApp(MaterialApp(
    title: 'CareShift',
    initialRoute: validation == null || !validation ? '/' : '/home',
    routes: {
      '/': (context) => const LoginPage(),
      '/home': (context) => const HomePage(),
    },
  ));
}
