// lib/services/token_manager.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _keyToken = 'saved_token';
  static const String _keyTokenExpiry = 'token_expiry';
  static const String _keyRefreshToken = 'refresh_token';
  
  static String? _currentToken;
  
  // Save token after login
  static Future<void> saveToken(String token, {String? refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    _currentToken = token;
    
    // Calculate expiry time from JWT
    final expiry = _getTokenExpiry(token);
    if (expiry != null) {
      await prefs.setInt(_keyTokenExpiry, expiry.millisecondsSinceEpoch);
    }
    
    if (refreshToken != null) {
      await prefs.setString(_keyRefreshToken, refreshToken);
    }
  }
  
  // Get current token
  static Future<String?> getToken() async {
    if (_currentToken != null) return _currentToken;
    
    final prefs = await SharedPreferences.getInstance();
    _currentToken = prefs.getString(_keyToken);
    return _currentToken;
  }
  
  // Check if token is expired
  static Future<bool> isTokenExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryMs = prefs.getInt(_keyTokenExpiry);
    
    if (expiryMs == null) return true;
    
    final expiry = DateTime.fromMillisecondsSinceEpoch(expiryMs);
    return DateTime.now().isAfter(expiry);
  }
  
  // Clear token (on logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyTokenExpiry);
    await prefs.remove(_keyRefreshToken);
    _currentToken = null;
  }
  
  // Extract expiry from JWT token
  static DateTime? _getTokenExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );
      
      if (payload['exp'] != null) {
        return DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
      }
    } catch (e) {
      print('Error parsing token expiry: $e');
    }
    return null;
  }
  
  // Get refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRefreshToken);
  }


  // Add this new method to TokenManager class
static Future<bool> hasValidToken() async {
  final token = await getToken();
  if (token == null || token.isEmpty) return false;
  
  final expired = await isTokenExpired();
  return !expired;
}

// Add this to get role from saved token without API call
static String? getRoleFromToken(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    
    final payload = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
    );
    return payload['role'] as String?;
  } catch (e) {
    print('Error parsing token role: $e');
    return null;
  }
}


}