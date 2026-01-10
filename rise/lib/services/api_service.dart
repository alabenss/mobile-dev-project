import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static ApiService get instance => _instance;

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Get current access token
  Future<String?> _getAccessToken() async {
    try {
      final session = _supabase.auth.currentSession;
      return session?.accessToken;
    } catch (e) {
      print('ApiService: Error getting access token: $e');
      return null;
    }
  }

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

  /// Get headers with authentication
  Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    
    final token = await _getAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
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
    } else if (response.statusCode == 401) {
      print('ApiService: Token expired, attempting refresh...');
      final refreshed = await _refreshToken();
      if (!refreshed) {
        throw Exception('Session expired. Please login again.');
      }
      throw Exception('TOKEN_REFRESH_REQUIRED');
    } else {
      final errorBody = response.body.isNotEmpty ? response.body : 'No error details';
      throw Exception('API Error ${response.statusCode}: $errorBody');
    }
  }

  /// Refresh access token
  Future<bool> _refreshToken() async {
    try {
      final session = await _supabase.auth.refreshSession();
      return session.session != null;
    } catch (e) {
      print('ApiService: Error refreshing token: $e');
      return false;
    }
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? params,
    int retryCount = 0,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.BASE_URL}$endpoint')
          .replace(queryParameters: params);

      print('ApiService GET: $uri');

      final headers = await _getHeaders();
      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } catch (e) {
      if (retryCount < 1 && e.toString().contains('TOKEN_REFRESH_REQUIRED')) {
        print('ApiService: Retrying GET after token refresh...');
        return await get(endpoint, params: params, retryCount: retryCount + 1);
      }
      print('ApiService GET Error: $e');
      rethrow;
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    int retryCount = 0,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.BASE_URL}$endpoint');
      
      print('ApiService POST: $uri');
      print('ApiService POST Body: ${jsonEncode(body)}');

      final headers = await _getHeaders();
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } catch (e) {
      if (retryCount < 1 && e.toString().contains('TOKEN_REFRESH_REQUIRED')) {
        print('ApiService: Retrying POST after token refresh...');
        return await post(endpoint, body, retryCount: retryCount + 1);
      }
      print('ApiService POST Error: $e');
      rethrow;
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    int retryCount = 0,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.BASE_URL}$endpoint');
      
      print('ApiService PUT: $uri');
      print('ApiService PUT Body: ${jsonEncode(body)}');

      final headers = await _getHeaders();
      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } catch (e) {
      if (retryCount < 1 && e.toString().contains('TOKEN_REFRESH_REQUIRED')) {
        print('ApiService: Retrying PUT after token refresh...');
        return await put(endpoint, body, retryCount: retryCount + 1);
      }
      print('ApiService PUT Error: $e');
      rethrow;
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? params,
    int retryCount = 0,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.BASE_URL}$endpoint')
          .replace(queryParameters: params);

      print('ApiService DELETE: $uri');

      final headers = await _getHeaders();
      final response = await http.delete(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      return await _handleResponse(response);
    } catch (e) {
      if (retryCount < 1 && e.toString().contains('TOKEN_REFRESH_REQUIRED')) {
        print('ApiService: Retrying DELETE after token refresh...');
        return await delete(endpoint, params: params, retryCount: retryCount + 1);
      }
      print('ApiService DELETE Error: $e');
      rethrow;
    }
  }

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