import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NetworkConfig {
  static const int backendPort = 5000;
  static String? _detectedIp;
  
  /// Auto-detect the backend IP by scanning common network ranges
  static Future<String?> detectBackendIP() async {
    if (_detectedIp != null) return _detectedIp;
    
    // Get local IP ranges to scan
    List<String> ipRanges = await _getLocalIPRanges();
    
    for (String baseIP in ipRanges) {
      String testUrl = 'http://$baseIP:$backendPort/api/health';
      
      try {
        if (kDebugMode) {
          print('Testing IP: $baseIP');
        }
        
        final response = await http.get(
          Uri.parse(testUrl),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 2));
        
        if (response.statusCode == 200) {
          _detectedIp = baseIP;
          if (kDebugMode) {
            print('Found backend at: $baseIP');
          }
          return baseIP;
        }
      } catch (e) {
        // Continue to next IP
      }
    }
    
    return null;
  }
  
  static Future<List<String>> _getLocalIPRanges() async {
    List<String> ips = ['localhost', '127.0.0.1'];
    
    try {
      // Get network interfaces
      List<NetworkInterface> interfaces = await NetworkInterface.list();
      
      for (NetworkInterface interface in interfaces) {
        for (InternetAddress address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
            ips.add(address.address);
            
            // Also add common variations
            String baseIP = address.address.substring(0, address.address.lastIndexOf('.'));
            for (int i = 1; i <= 20; i++) {
              ips.add('$baseIP.$i');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting network interfaces: $e');
      }
    }
    
    return ips.toSet().toList(); // Remove duplicates
  }
}