import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_parking/blocs/auth_bloc.dart';
import 'package:smart_parking/constants/constants.dart';
import 'package:smart_parking/screens/login_screen.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => AuthBloc(),
      child: SmartParkingApp(),
    ),
  );
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
