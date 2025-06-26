import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL for the backend API with a getter to allow for runtime configuration
  // Update your _baseUrl depending on where you're running the app

  // For Android emulator, use 10.0.2.2 instead of localhost
  static String _baseUrl = 'http://10.0.2.2:5000/api';

  // Or use your machine's actual IP address
  // static String _baseUrl = 'http://192.168.1.xxx:5000/api';
  
  // Getter for baseUrl
  static String get baseUrl => _baseUrl;
  
  // Setter for baseUrl - can be called at app startup to configure the proper URL
  static set baseUrl(String url) {
    _baseUrl = url;
  }

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
    final token = prefs.getString(accessTokenKey);
    
    if (token == null) {
      if (kDebugMode) {
        print('No access token found in storage');
      }
      return null;
    }
    
    if (kDebugMode) {
      print('Retrieved access token from storage: ${token.substring(0, min(10, token.length))}...');
    }
    
    return token;
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

  // Add this property to store the current user ID
  int? _currentUserId;

  // Store user data along with ID
  Future<void> setUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userDataKey, jsonEncode(userData));
    // Store the user ID
    _currentUserId = userData['id'];
    await prefs.setInt('current_user_id', userData['id']);
  }

  // Update the getUserData method to use the stored ID
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      // Get the stored user ID from preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('current_user_id') ?? _currentUserId;
      
      if (userId == null) {
        return null;
      }
      
      // Fetch user data using the ID
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
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
    await prefs.remove('username'); // Add this line
    await prefs.remove('current_user_id'); // Add this line
  }

  // Helper method to get authorization headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getAccessToken();
    
    if (kDebugMode) {
      print('Authorization header: ${token != null ? "Bearer ${token.substring(0, min(10, token.length))}..." : "MISSING"}');
    }
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Generic HTTP methods with token handling
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (kDebugMode) {
      print('Response status code: ${response.statusCode}');
      print('Response body length: ${response.body.length}');
    }
    
    // Handle empty responses
    if (response.body.isEmpty) {
      throw Exception('Empty response from server');
    }
    
    // Safely parse response
    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body);
    } catch (e) {
      if (kDebugMode) {
        print('JSON parse error: $e');
        print('Raw response: "${response.body}"');
      }
      throw Exception('Invalid JSON response from server');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else if (response.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await refreshToken();
      if (refreshed) {
        throw Exception('Token expired. Please retry the request.');
      } else {
        await clearStoredData();
        throw Exception('Authentication required. Please log in again.');
      }
    } else {
      throw Exception(data['message'] ?? 'Request failed with status ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      // Ensure endpoint starts with / for proper path construction
      String path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
      final headers = await _getAuthHeaders();
      
      if (kDebugMode) {
        print('GET request to: $baseUrl$path');
      }
      
      final response = await _client.get(
        Uri.parse('$baseUrl$path'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
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
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save the access token and refresh token
        if (data['tokens'] != null) {
          final accessToken = data['tokens']['access_token'];
          final refreshToken = data['tokens']['refresh_token'];
          await setTokens(accessToken, refreshToken);
          
          // Save the username for future use
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username);
          
          // Also get current user data to ensure we have the latest info
          try {
            final userInfo = await getCurrentUser();
            if (userInfo != null) {
              await setUserData(userInfo);
            }
          } catch (e) {
            print('Warning: Could not fetch user data after login: $e');
          }
          
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
  // ...existing code...

  Future<bool> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(refreshTokenKey);
      
      if (refreshToken == null) return false;

      final response = await _client.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString(accessTokenKey, data['access_token']);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Refresh token error: $e');
      }
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final token = await getAccessToken();
      if (token != null) {
        try {
          await _client.post(
            Uri.parse('$baseUrl/auth/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
        } catch (e) {
          // Ignore errors during logout request
        }
      }
    } finally {
      // Always clear local storage including username
      await clearStoredData();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');
    }
  }

  Future<String?> getSecurityQuestion(String username) async {
    try {
      if (kDebugMode) {
        print('Requesting security question for username: $username');
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/auth/password-recovery/question'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );
      
      // Enhanced debug information
      if (kDebugMode) {
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        print('Request URL: ${Uri.parse('$baseUrl/auth/password-recovery/question')}');
      }
      
      if (response.body.isEmpty) {
        throw Exception('Backend returned an empty response');
      }
      
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        if (kDebugMode) {
          print('JSON parse error: $e');
        }
        throw Exception('Invalid JSON response from server');
      }
      
      if (response.statusCode == 200) {
        return data['security_question'];
      } else if (response.statusCode == 404) {
        return null; // User not found
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

  // // Verify security answer
  // Future<String?> verifySecurityAnswer(String username, String answer) async {
  //   try {
  //     final response = await _client.post(
  //       Uri.parse('$baseUrl/auth/password-recovery/verify'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'username': username,
  //         'answer': answer,
  //       }),
  //     );
      
  //     final data = jsonDecode(response.body);
      
  //     if (response.statusCode == 200) {
  //       return data['reset_token'];
  //     } else {
  //       throw Exception(data['message'] ?? 'Incorrect answer');
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('Verify security answer error: $e');
  //     }
  //     return null;
  //   }
  // }

  Future<String> verifySecurityAnswer(String username, String answer) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/password-recovery/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'answer': answer
        }),
      );
      
      if (kDebugMode) {
        print('Verify security answer status code: ${response.statusCode}');
      }
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['reset_token'];
        
        // Debug the token format
        if (kDebugMode) {
          print('Token received length: ${token?.length}');
          print('Token contains dots: ${token?.contains('.')}');
          print('Token segments: ${token?.split('.').length}');
        }
        
        if (token == null || token.isEmpty) {
          throw Exception('No token received from server');
        }
        
        return token;
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to verify security answer');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Verify security answer error: $e');
      }
      throw e;
    }
  }

  // Reset password
  Future<bool> resetPassword(String resetToken, String newPassword) async {
    try {
      // Debug the token before sending
      if (kDebugMode) {
        print('Reset token length: ${resetToken.length}');
        print('Reset token segments: ${resetToken.split('.').length}');
        
        if (resetToken.split('.').length != 3) {
          print('WARNING: JWT token does not have 3 segments!');
        }
      }
      
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/password-recovery/reset'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $resetToken',
        },
        body: jsonEncode({'password': newPassword}),
      );
      
      if (kDebugMode) {
        print('Reset password status code: ${response.statusCode}');
        print('Reset password response: ${response.body}');
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Request failed');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('Reset password error: $e');
      }
      throw e;
    }
  }

  // User management methods
  Future<Map<String, dynamic>?> createUserFromData(Map<String, dynamic> userData) async {
    try {
      // Remove email field if it exists
      Map<String, dynamic> cleanData = {...userData};
      cleanData.remove('email');
      
      final result = await post('/users', cleanData);
      return result['user'];
    } catch (e) {
      if (kDebugMode) {
        print('Create user error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>> createUser(
    String username, 
    String password, 
    String securityQuestion, 
    String securityAnswer,
    bool isAdmin,
  ) async {
    try {
      // Use a unique identifier to prevent caching issues
      final uniqueId = DateTime.now().millisecondsSinceEpoch;
      
      // First reset the session using the proper API call pattern
      try {
        await get('/auth/reset-session?_nocache=$uniqueId');
      } catch (e) {
        // Ignore errors from reset_session as it might not be critical
        if (kDebugMode) {
          print('Session reset warning (non-critical): $e');
        }
      }
      
      // Now make the register call using the post helper method
      final result = await post('/auth/register?_nocache=$uniqueId', {
        'username': username,
        'password': password,
        'security_question': securityQuestion,
        'security_answer': securityAnswer,
        'is_admin': isAdmin,
        'timestamp': uniqueId.toString(),
      });
      
      // Reset session again after registration (using proper pattern)
      try {
        await get('/auth/reset-session?_nocache=$uniqueId');
      } catch (e) {
        // Ignore errors
      }
      
      return {'success': true, 'message': 'User registered successfully'};
    } catch (e) {
      if (kDebugMode) {
        print('User registration error: $e');
      }
      return {'success': false, 'message': e.toString()};
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

  Future<Map<String, dynamic>> getUser(int userId) async {
    try {
      // Make sure you have valid authentication headers
      final headers = await _getAuthHeaders(); // This should include your JWT token
      
      final response = await _client.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
      );
      
      // Handle the response
      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        print('Get user error: $e');
      }
      throw Exception('Failed to get user: $e');
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
      final token = await getAccessToken();
      if (token == null) {
        return null;
      }

      final response = await _client.put(
        Uri.parse('$baseUrl/machinery/$machineryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(machineryData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['machinery'];
      } else {
        if (kDebugMode) {
          print('Update machinery error: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Update machinery error: $e');
      }
      return null;
    }
  }

  Future<bool> deleteMachinery(int machineryId) async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        return false;
      }

      final response = await _client.delete(
        Uri.parse('$baseUrl/machinery/$machineryId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
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

  // Add this method to the ApiService class

  Future<bool> signup(Map<String, dynamic> userData) async {
    try {
      if (kDebugMode) {
        print('Attempting signup with data: ${userData.toString()}');
        print('Signup URL: $baseUrl/auth/signup');
      }

      // The signup endpoint should not require authentication
      final response = await _client.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      ).timeout(const Duration(seconds: 15)); // Increase timeout for signup
      
      // Debug information
      if (kDebugMode) {
        print('Signup response status code: ${response.statusCode}');
        print('Signup response body: ${response.body}');
      }
      
      if (response.statusCode == 201) {
        // Try to parse response data if available
        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);
            
            // If the backend returns tokens directly after signup
            if (data['tokens'] != null) {
              await setTokens(
                data['tokens']['access_token'],
                data['tokens']['refresh_token'],
              );
              
              // Store user data if available
              if (data['user'] != null) {
                await setUserData(data['user']);
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print('Warning: Could not parse signup response: $e');
            }
          }
        }
        return true;
      } else {
        // Handle non-201 status codes
        String errorMessage = 'Unknown error';
        try {
          if (response.body.isNotEmpty) {
            final data = jsonDecode(response.body);
            errorMessage = data['message'] ?? 'Unknown error';
          }
        } catch (e) {
          errorMessage = 'Could not parse error response';
        }
        
        if (kDebugMode) {
          print('Signup failed: $errorMessage');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Signup error: $e');
      }
      return false;
    }
  }

  // Add this method to your ApiService class

  Future<Map<String, dynamic>> checkBackendConnection() async {
    try {
      if (kDebugMode) {
        print('Testing backend connectivity to: $baseUrl');
      }

      // First, try a simple GET request to the root endpoint
      final rootResponse = await _client.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      // Then try a health check endpoint if available
      final healthResponse = await _client.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      return {
        'connected': true,
        'root_status': rootResponse.statusCode,
        'health_status': healthResponse.statusCode,
        'root_body': rootResponse.body,
        'health_body': healthResponse.body,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Backend connectivity test failed: $e');
      }
      
      // Try to determine if it's a connection refused error
      String errorType = 'unknown';
      if (e.toString().contains('Connection refused')) {
        errorType = 'connection_refused';
      } else if (e.toString().contains('SocketException')) {
        errorType = 'socket_exception';
      } else if (e.toString().contains('timeout')) {
        errorType = 'timeout';
      }
      
      return {
        'connected': false,
        'error': e.toString(),
        'error_type': errorType
      };
    }
  }

  // Add this method to auto-detect the working base URL

  Future<bool> autoConfigureBaseUrl() async {
    List<String> possibleUrls = [
      'http://localhost:5000/api',
      'http://10.0.2.2:5000/api',  // For Android emulator
      'http://127.0.0.1:5000/api',
      // Add any other potential URLs including your actual IP address
    ];
    
    for (String url in possibleUrls) {
      if (kDebugMode) {
        print('Trying base URL: $url');
      }
      
      _baseUrl = url;
      
      try {
        final response = await _client.get(
          Uri.parse('$url/health'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 2));
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (kDebugMode) {
            print('Successfully connected to: $url');
          }
          return true;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to connect to $url: $e');
        }
        // Continue to next URL
      }
    }
    
    return false;
  }

  // Add this method to your ApiService class

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        return null;
      }
      
      final response = await _client.get(
        Uri.parse('$baseUrl/auth/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to get user info: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

  // Add these methods to your existing ApiService class:

  // Repair management methods
  Future<Map<String, dynamic>?> createRepair(Map<String, dynamic> repairData) async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await _client.post(
        Uri.parse('$baseUrl/repairs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(repairData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['repair'];
      } else {
        if (kDebugMode) {
          print('Create repair error: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Create repair error: $e');
      }
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getRepairs() async {
    try {
      final result = await get('/repairs');
      final List<dynamic> repairsData = result['repairs'];
      return repairsData.map((repair) => repair as Map<String, dynamic>).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Get repairs error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> getRepairById(int repairId) async {
    try {
      final result = await get('/repairs/$repairId');
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Get repair by ID error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateRepair(int repairId, Map<String, dynamic> repairData) async {
    try {
      final result = await put('/repairs/$repairId', repairData);
      return result['repair'];
    } catch (e) {
      if (kDebugMode) {
        print('Update repair error: $e');
      }
      return null;
    }
  }

  Future<bool> deleteRepair(int repairId) async {
    try {
      await delete('/repairs/$repairId');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Delete repair error: $e');
      }
      return false;
    }
  }

  // Add this method to search for repairs by parts
  Future<List<Map<String, dynamic>>?> searchRepairsByParts(String partName) async {
    try {
      final result = await get('/repairs');
      final List<dynamic> repairsData = result['repairs'];
      
      // Filter repairs based on parts concerned (stored in notes field)
      final filteredRepairs = repairsData
          .map((repair) => repair as Map<String, dynamic>)
          .where((repair) => 
              repair['notes'] != null && 
              repair['notes'].toString().toLowerCase().contains(partName.toLowerCase()))
          .toList();
          
      return filteredRepairs;
    } catch (e) {
      if (kDebugMode) {
        print('Search repairs by parts error: $e');
      }
      return null;
    }
  }

  // Add this method to ApiService class
  Future<void> resetSession() async {
    // Clear any cached data that might be causing issues
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('temp_user_data');
  }
  
   Future<Map<String, dynamic>?> restoreMachinery(List<dynamic> machineryData) async {
    try {
      final result = await post('/machinery/restore', {'machinery': machineryData});
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Restore machinery error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> restoreRiceVarieties(List<dynamic> riceData) async {
    try {
      final result = await post('/rice-varieties/restore', {'rice_varieties': riceData});
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Restore rice varieties error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> restoreUsers(List<dynamic> usersData) async {
    try {
      final result = await post('/users/restore', {'users': usersData});
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Restore users error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> restoreFullBackup(Map<String, dynamic> backupData) async {
    try {
      final result = await post('/restore', backupData);
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Restore full backup error: $e');
      }
      return null;
    }
  }

    Future<Map<String, dynamic>?> createProductionRecord(Map<String, dynamic> productionData) async {
    try {
      final result = await post('/production', productionData);
      return result['production_record'];
    } catch (e) {
      if (kDebugMode) {
        print('Create production record error: $e');
      }
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getProductionRecords() async {
    try {
      final result = await get('/production');
      final List<dynamic> productionData = result['production_records'];
      return productionData.map((record) => record as Map<String, dynamic>).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Get production records error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProductionRecordById(int recordId) async {
    try {
      final result = await get('/production/$recordId');
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Get production record by ID error: $e');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateProductionRecord(int recordId, Map<String, dynamic> productionData) async {
    try {
      final result = await put('/production/$recordId', productionData);
      return result['production_record'];
    } catch (e) {
      if (kDebugMode) {
        print('Update production record error: $e');
      }
      return null;
    }
  }

  Future<bool> deleteProductionRecord(int recordId) async {
    try {
      await delete('/production/$recordId');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Delete production record error: $e');
      }
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> searchRiceVarietiesByGrade(String qualityGrade) async {
  try {
    final result = await get('/rice/search?quality_grade=$qualityGrade');
    final List<dynamic> riceData = result['rice_varieties'];
    return riceData.map((rice) => rice as Map<String, dynamic>).toList();
  } catch (e) {
    if (kDebugMode) {
      print('Search rice varieties by grade error: $e');
    }
    return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getForecastData(String riceVariety) async {
    try {
      print('Fetching forecast data for variety: $riceVariety'); // Debug log
      
      final queryParam = riceVariety == 'All' ? '' : '?variety=$riceVariety';
      final result = await get('/forecast/sarima$queryParam');
      
      print('Forecast API response: $result'); // Debug log
      
      if (result != null && result['forecast'] != null) {
        final List<dynamic> forecastData = result['forecast'];
        print('Forecast data length: ${forecastData.length}'); // Debug log
        return forecastData.map((item) => item as Map<String, dynamic>).toList();
      }
      
      // Return empty list instead of null if no forecast available
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Get forecast data error: $e');
      }
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCurrentYieldSummary() async {
    try {
      print('Making API call to /forecast/current-summary'); // Debug log
      
      // Use the correct endpoint with proper HTTP method
      final response = await http.get(
        Uri.parse('$baseUrl/forecast/current-summary'),
        headers: await _getAuthHeaders(),
      );
      
      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Parsed result: $result'); // Debug log
        
        // Ensure all values are properly typed
        return {
          'total_yield': (result['total_yield'] ?? 0).toDouble(),
          'total_records': (result['total_records'] ?? 0).toInt(),
          'avg_production': (result['avg_production'] ?? 0).toDouble(),
          'accuracy': (result['accuracy'] ?? 95.2).toDouble(),
        };
      } else {
        print('API call failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Get current yield summary error: $e');
      }
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> generateForecast(Map<String, dynamic> parameters) async {
    try {
      final result = await post('/forecast/generate', parameters);
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Generate forecast error: $e');
      }
      return null;
    }
  }

  // Machine Assignment methods
Future<List<Map<String, dynamic>>?> getAssignments() async {
  try {
    final result = await get('/assignments');
    final List<dynamic> assignmentData = result['assignments'];
    return assignmentData.map((assignment) => assignment as Map<String, dynamic>).toList();
  } catch (e) {
    if (kDebugMode) {
      print('Get assignments error: $e');
    }
    return null;
  }
}

Future<List<Map<String, dynamic>>?> getActiveAssignments() async {
  try {
    final result = await get('/assignments/active');
    final List<dynamic> assignmentData = result['assignments'];
    return assignmentData.map((assignment) => assignment as Map<String, dynamic>).toList();
  } catch (e) {
    if (kDebugMode) {
      print('Get active assignments error: $e');
    }
    return null;
  }
}

Future<List<Map<String, dynamic>>?> getAvailableMachinery() async {
  try {
    final result = await get('/machinery/available');
    final List<dynamic> machineryData = result['machinery'];
    return machineryData.map((machinery) => machinery as Map<String, dynamic>).toList();
  } catch (e) {
    if (kDebugMode) {
      print('Get available machinery error: $e');
    }
    return null;
  }
}

Future<Map<String, dynamic>?> createAssignment(Map<String, dynamic> assignmentData) async {
  try {
    final result = await post('/assignments', assignmentData);
    return result['assignment'];
  } catch (e) {
    if (kDebugMode) {
      print('Create assignment error: $e');
    }
    return null;
  }
}

Future<Map<String, dynamic>?> returnAssignment(int assignmentId, Map<String, dynamic> returnData) async {
  try {
    final token = await getAccessToken();
    if (token == null) {
      return null;
    }

    final response = await _client.put(
      Uri.parse('$baseUrl/assignments/$assignmentId/return'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(returnData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['assignment'];
    } else {
      if (kDebugMode) {
        print('Return assignment error: ${response.body}');
      }
      return null;
    }
  } catch (e) {
    if (kDebugMode) {
      print('Return assignment error: $e');
    }
    return null;
  }
}

Future<bool> deleteAssignment(int assignmentId) async {
  try {
    final token = await getAccessToken();
    if (token == null) {
      return false;
    }

    final response = await _client.delete(
      Uri.parse('$baseUrl/assignments/$assignmentId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  } catch (e) {
    if (kDebugMode) {
      print('Delete assignment error: $e');
    }
    return false;
  }
}
}