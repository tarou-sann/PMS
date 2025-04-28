import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL for the backend API
  // Change this to your LAN IP address when running on physical devices
  static const String baseUrl = 'http://localhost:5000/api'; // Default for Android emulator
  // For iOS simulator, use: 'http://localhost:5000/api'
  // For physical devices, use your computer's LAN IP, e.g. 'http://192.168.1.100:5000/api'

  // Token storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';

  // HTTP client
  final http.Client _client = http.Client();

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _prefs = SharedPreferences.getInstance();

  // Get stored tokens
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(refreshTokenKey);
  }

  // Store tokens
  Future<void> setTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(accessTokenKey, accessToken);
    await prefs.setString(refreshTokenKey, refreshToken);
  }

  // Store user data
  Future<void> setUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userDataKey, jsonEncode(userData));
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }

  // Clear stored data on logout
  Future<void> clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
    await prefs.remove(userDataKey);
  }

  // Helper method to get authorization headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Generic HTTP methods with token handling
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final data = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else if (response.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await refreshToken();
      if (refreshed) {
        // Retry the original request
        // Note: This is a simplified implementation
        throw Exception('Token expired. Please retry the request.');
      } else {
        // Refresh failed, log out
        await clearStoredData();
        throw Exception('Authentication required. Please log in again.');
      }
    } else {
      throw Exception(data['message'] ?? 'Request failed');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  // Authentication methods
  Future<bool> login(String username, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        await setTokens(
          data['tokens']['access_token'],
          data['tokens']['refresh_token'],
        );
        await setUserData(data['user']);
        return true;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      return false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final prefs = await _prefs;
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString('access_token', data['access_token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Refresh token error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await clearStoredData();
  }

  // Get security question for password recovery
  Future<String?> getSecurityQuestion(String username) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/password-recovery/question'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return data['security_question'];
      } else {
        throw Exception(data['message'] ?? 'Failed to get security question');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Get security question error: $e');
      }
      return null;
    }
  }

  // Verify security answer
  Future<String?> verifySecurityAnswer(String username, String answer) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/password-recovery/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'answer': answer,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return data['reset_token'];
      } else {
        throw Exception(data['message'] ?? 'Incorrect answer');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Verify security answer error: $e');
      }
      return null;
    }
  }

  // Reset password
  Future<bool> resetPassword(String resetToken, String newPassword) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/password-recovery/reset'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $resetToken',
        },
        body: jsonEncode({'password': newPassword}),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(data['message'] ?? 'Password reset failed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Reset password error: $e');
      }
      return false;
    }
  }

  // User management methods
  Future<Map<String, dynamic>?> createUser(Map<String, dynamic> userData) async {
    try {
      final result = await post('/users', userData);
      return result['user'];
    } catch (e) {
      if (kDebugMode) {
        print('Create user error: $e');
      }
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getUsers() async {
    try {
      final result = await get('/users');
      final List<dynamic> usersData = result['users'];
      return usersData.map((user) => user as Map<String, dynamic>).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Get users error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUser(int userId) async {
    try {
      final result = await get('/users/$userId');
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Get user error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      final result = await put('/users/$userId', userData);
      return result['user'];
    } catch (e) {
      if (kDebugMode) {
        print('Update user error: $e');
      }
      return null;
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      await delete('/users/$userId');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Delete user error: $e');
      }
      return false;
    }
  }

  // Machinery management methods
  Future<Map<String, dynamic>?> createMachinery(Map<String, dynamic> machineryData) async {
    try {
      final result = await post('/machinery', machineryData);
      return result['machinery'];
    } catch (e) {
      if (kDebugMode) {
        print('Create machinery error: $e');
      }
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getMachinery() async {
    try {
      final result = await get('/machinery');
      final List<dynamic> machineryData = result['machinery'];
      return machineryData.map((machinery) => machinery as Map<String, dynamic>).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Get machinery error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMachineryById(int machineryId) async {
    try {
      final result = await get('/machinery/$machineryId');
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Get machinery by ID error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateMachinery(int machineryId, Map<String, dynamic> machineryData) async {
    try {
      final result = await put('/machinery/$machineryId', machineryData);
      return result['machinery'];
    } catch (e) {
      if (kDebugMode) {
        print('Update machinery error: $e');
      }
      return null;
    }
  }

  Future<bool> deleteMachinery(int machineryId) async {
    try {
      await delete('/machinery/$machineryId');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Delete machinery error: $e');
      }
      return false;
    }
  }

  // Rice variety management methods
  Future<Map<String, dynamic>?> createRiceVariety(Map<String, dynamic> riceData) async {
    try {
      final result = await post('/rice', riceData);
      return result['rice_variety'];
    } catch (e) {
      if (kDebugMode) {
        print('Create rice variety error: $e');
      }
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getRiceVarieties() async {
    try {
      final result = await get('/rice');
      final List<dynamic> riceData = result['rice_varieties'];
      return riceData.map((rice) => rice as Map<String, dynamic>).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Get rice varieties error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> getRiceVarietyById(int riceId) async {
    try {
      final result = await get('/rice/$riceId');
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Get rice variety by ID error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateRiceVariety(int riceId, Map<String, dynamic> riceData) async {
    try {
      final result = await put('/rice/$riceId', riceData);
      return result['rice_variety'];
    } catch (e) {
      if (kDebugMode) {
        print('Update rice variety error: $e');
      }
      return null;
    }
  }

  Future<bool> deleteRiceVariety(int riceId) async {
    try {
      await delete('/rice/$riceId');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Delete rice variety error: $e');
      }
      return false;
    }
  }
}