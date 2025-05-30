import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_service.dart';

class UserActivityService {
  static final UserActivityService _instance = UserActivityService._internal();
  factory UserActivityService() => _instance;
  UserActivityService._internal();

  final ApiService _apiService = ApiService();

  // Log user activity
  Future<void> logActivity(String action, String details, {String? target}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? 'Unknown User';
      
      final activityData = {
        'username': username,
        'action': action,
        'details': details,
        'target': target,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Send to backend
      await _apiService.post('/activity-logs', activityData);
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  // Get user activities
  Future<List<Map<String, dynamic>>?> getUserActivities() async {
    try {
      final result = await _apiService.get('/activity-logs');
      if (result['activities'] != null) {
        return List<Map<String, dynamic>>.from(result['activities']);
      }
      return null;
    } catch (e) {
      print('Error getting user activities: $e');
      return null;
    }
  }
}