import 'package:flutter/material.dart';
import 'package:pms_frontend/pages/machinerymanagement.dart';
import 'package:pms_frontend/pages/repair.dart';
import 'theme/themedata.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PMS Frontend',
      theme: theme,
      home: const MachineryManagementNav(), // Start with the login screen
      debugShowCheckedModeBanner: false,
    );
  }
}
