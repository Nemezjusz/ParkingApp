import 'package:flutter/material.dart';
import 'package:smart_parking/constants/constants.dart';
import 'package:smart_parking/screens/login_screen.dart';


void main() {
  runApp(SmartParkingApp());
}

class SmartParkingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Parking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: LoginScreen(),
    );
  }
}
