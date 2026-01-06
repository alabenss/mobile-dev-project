// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Get instance
  static ApiService get instance => _instance;

  /// Get current user ID from SharedPreferences
  Future<int?> _getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('userId');
    } catch (e) {
      print('ApiService: Error getting userId: $e');
      return null;
    }
  }

  /// Handle API response
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    print('ApiService: Response status: ${response.statusCode}');
    print('ApiService: Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Failed to parse response: $e');
      }
    } else {
      final errorBody = response.body.isNotEmpty ? response.body : 'No error details';
      throw Exception('API Error ${response.statusCode}: $errorBody');
    }
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? params,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.BASE_URL}$endpoint')
          .replace(queryParameters: params);

      print('ApiService GET: $uri');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } catch (e) {
      print('ApiService GET Error: $e');
      rethrow;
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('${ApiConfig.BASE_URL}$endpoint');
      
      print('ApiService POST: $uri');
      print('ApiService POST Body: ${jsonEncode(body)}');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } catch (e) {
      print('ApiService POST Error: $e');
      rethrow;
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final uri = Uri.parse('${ApiConfig.BASE_URL}$endpoint');
      
      print('ApiService PUT: $uri');
      print('ApiService PUT Body: ${jsonEncode(body)}');

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } catch (e) {
      print('ApiService PUT Error: $e');
      rethrow;
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? params,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.BASE_URL}$endpoint')
          .replace(queryParameters: params);

      print('ApiService DELETE: $uri');

      final response = await http.delete(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } catch (e) {
      print('ApiService DELETE Error: $e');
      rethrow;
    }
  }

  // ============ Convenience Methods ============

  /// Get current user ID (helper for repositories)
  Future<int> getCurrentUserId() async {
    final userId = await _getUserId();
    if (userId == null) {
      throw Exception('User not logged in');
    }
    return userId;
  }

  /// Format date as yyyy-MM-dd
  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get today's date as yyyy-MM-dd string
  String getTodayString() {
    return formatDate(DateTime.now());
  }
}