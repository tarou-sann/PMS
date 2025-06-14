import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pms_frontend/pages/signup.dart';
import 'package:pms_frontend/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important for async operations in main

  // Configure API URL based on platform
  if (kIsWeb) {
    ApiService.baseUrl = '/api';
  } else if (Platform.isAndroid) {
    ApiService.baseUrl = 'http://10.0.2.2:5000/api';
  } else {
    ApiService.baseUrl = 'http://localhost:5000/api';
  }

  // Try auto-configuring the base URL
  await ApiService().autoConfigureBaseUrl();

  // Test if backend is accessible
  final connectionTest = await ApiService().checkBackendConnection();
  if (kDebugMode) {
    print('Backend connection test: ${connectionTest['connected']}');
    if (!connectionTest['connected']) {
      print('Connection error: ${connectionTest['error']}');
      print('Error type: ${connectionTest['error_type']}');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PMS Frontend',
      theme: ThemeData(
        fontFamily: 'Lexend',
      ),
      home: const SignUpForm(),
      debugShowCheckedModeBanner: false,
    );
  }
}
