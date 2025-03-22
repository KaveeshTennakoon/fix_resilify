import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Change this to your actual backend URL
  static const String baseUrl = 'http://localhost:5000/api';

  // Current user ID (will be set by auth service)
  String? _currentUserId;

  // Set current user ID
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
  }

  // Helper method for authenticated HTTP requests
  Future<http.Response> _authenticatedRequest(
      String endpoint,
      String method,
      {Map<String, dynamic>? body}
      ) async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    final headers = {
      'Content-Type': 'application/json',
      'X-User-UID': _currentUserId!,  // Send user UID in header
    };

    final Uri url = Uri.parse('$baseUrl/$endpoint/');

    try {
      switch (method) {
        case 'GET':
          return await http.get(url, headers: headers);
        case 'POST':
          return await http.post(
            url,
            headers: headers,
            body: jsonEncode(body),
          );
        case 'PUT':
          return await http.put(
            url,
            headers: headers,
            body: jsonEncode(body),
          );
        case 'DELETE':
          return await http.delete(url, headers: headers);
        default:
          throw Exception('Unsupported HTTP method');
      }
    } catch (e) {
      if (kDebugMode) {
        print('API Error: $e');
      }
      rethrow;
    }
  }

  // USER OPERATIONS

  // Create/Update user profile in backend
  Future<Map<String, dynamic>> syncUserProfile({
    required String firstName,
    required String lastName,
    required String email
  }) async {
    final userData = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };

    final response = await _authenticatedRequest(
      'users',
      'POST',
      body: userData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to sync user profile: ${response.body}');
  }

  // Get user from backend
  Future<Map<String, dynamic>> getUserProfile() async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    final response = await _authenticatedRequest(
      'users/$_currentUserId',
      'GET',
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get user profile: ${response.body}');
  }

  // GAME SESSION OPERATIONS

  // Save game session to backend
  Future<Map<String, dynamic>> saveGameSession({
    required DateTime timePlayed,
    required int duration,
    required int points,
    required String activityType,
  }) async {
    final sessionData = {
      'time_played': timePlayed.toIso8601String(),
      'duration': duration,
      'points': points,
      'activity_type': activityType,
    };

    final response = await _authenticatedRequest(
      'game-sessions',
      'POST',
      body: sessionData,
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to save game session: ${response.body}');
  }

  // Fetch all game sessions for current user
  Future<List<Map<String, dynamic>>> getUserGameSessions() async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    final response = await _authenticatedRequest(
      'game-sessions/user/$_currentUserId',
      'GET',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to get user game sessions: ${response.body}');
  }

  // SENTIMENT DATA OPERATIONS

  // Save sentiment data to backend
  Future<Map<String, dynamic>> saveSentimentData({
    required DateTime time,
    required double score,
    required String prompt,
    String? sentimentId,
  }) async {
    final data = {
      'time': time.toIso8601String(),
      'score': score,
      'prompt': prompt,
      'sentiment_id': sentimentId,
    };

    final response = await _authenticatedRequest(
      'sentiments',
      'POST',
      body: data,
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to save sentiment data: ${response.body}');
  }

  // Get user stats
  Future<Map<String, dynamic>> getUserStats() async {
    if (_currentUserId == null) throw Exception('User not authenticated');

    final response = await _authenticatedRequest(
      'users/$_currentUserId/stats',
      'GET',
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to get user stats: ${response.body}');
  }
}