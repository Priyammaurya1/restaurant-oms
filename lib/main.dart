import 'package:flutter/material.dart';
import 'package:restaurent/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Management',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Color(0xFFF8F9FA),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFF6B35),
          elevation: 0,
        ),
      ),
      home: HomeScreen(),
    );
  }
}
