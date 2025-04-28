import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pms_frontend/pages/signup.dart';
import 'package:pms_frontend/services/api_service.dart';
import 'theme/themedata.dart';
import 'dart:io' show Platform;

void main() {
  // Configure the API base URL based on platform
  if (kIsWeb) {
    // For web, use relative URL
    ApiService.baseUrl = '/api';
  } else if (Platform.isAndroid) {
    // For Android emulator
    ApiService.baseUrl = 'http://10.0.2.2:5000/api';
  } else {
    // For iOS simulator or physical devices, keep default
    // You might want to set this to the LAN IP when running on physical devices
    ApiService.baseUrl = 'http://localhost:5000/api';
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PMS Frontend',
      theme: theme,
      home: const SignUpForm(), // Start with the login screen
      debugShowCheckedModeBanner: false,
    );
  }
}