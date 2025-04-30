import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();
  
  final ApiService _apiService = ApiService();
  
  // Cache the username to avoid unnecessary loading
  String? _cachedUsername;
  
  Future<String> getUsername() async {
    if (_cachedUsername != null) {
      return _cachedUsername!;
    }
    
    final prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? "";
    
    if (username.isEmpty) {
      try {
        final userInfo = await _apiService.getCurrentUser();
        if (userInfo != null && userInfo.containsKey('username')) {
          username = userInfo['username'];
          // Save for future use
          await prefs.setString('username', username);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching user: $e');
        }
        username = "Guest";
      }
    }
    
    _cachedUsername = username;
    return username;
  }
  
  void clearCache() {
    _cachedUsername = null;
  }
}