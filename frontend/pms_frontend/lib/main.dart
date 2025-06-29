import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pms_frontend/pages/signup.dart';
import 'package:pms_frontend/services/api_service.dart';

import 'theme/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    print('=== PMS Frontend Starting ===');
  }

  // Configure API URL based on platform
  if (kIsWeb) {
    ApiService.baseUrl = 'http://localhost:5000/api';
    if (kDebugMode) {
      print('Web platform - Base URL: ${ApiService.baseUrl}');
    }
  } else if (Platform.isAndroid) {
    ApiService.baseUrl = 'http://10.0.2.2:5000/api';
  } else {
    ApiService.baseUrl = 'http://localhost:5000/api';
  }

  final apiService = ApiService();
  
  // Test direct connection first
  await apiService.testDirectConnection();
  
  // Try auto-configuring the base URL
  final autoConfigured = await apiService.autoConfigureBaseUrl();
  
  final connectionTest = await apiService.checkBackendConnection();
  
  if (kDebugMode) {
    print('=== CONNECTION RESULTS ===');
    print('Auto-configured: $autoConfigured');
    print('Backend connected: ${connectionTest['connected']}');
    if (!connectionTest['connected']) {
      print('Error: ${connectionTest['error']}');
    }
    print('Final base URL: ${ApiService.baseUrl}');
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
        fontFamily: 'Urbanist',
        scaffoldBackgroundColor: ThemeColor.white,
      ),
      home: const SignUpForm(),
      debugShowCheckedModeBanner: false,
    );
  }
}
