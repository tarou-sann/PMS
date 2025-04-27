import 'package:flutter/material.dart';
import 'package:pms_frontend/pages/passwordrecovery.dart';
import 'package:pms_frontend/pages/register.dart';
import 'package:pms_frontend/pages/signup.dart';
import 'widget/navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PMS Frontend',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SignUpForm(), // Start with the login screen
      debugShowCheckedModeBanner: false,
    );
  }
}