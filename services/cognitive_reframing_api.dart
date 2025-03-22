import 'dart:convert';
import 'package:http/http.dart' as http;
import 'message_item.dart';

class CognitiveReframingAPI {
  static const String apiUrl = "http://82.29.162.82:5000/chat";

  static Future<String?> sendThought(String thought, int userId) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "message": thought,
          "user_id": userId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        String reframedThought = responseData['response'] ?? "Reframed thought not found";
        // Remove numbers from the response
        return reframedThought.replaceAll(RegExp(r'\d'), '');
      } else {
        return "Error: ${response.statusCode} - ${response.reasonPhrase}";
      }
    } catch (e) {
      return "Failed to connect to server: $e";
    }
  }

  static Future<List<MessageItem>> getHistory(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("http://82.29.162.82:5000/history?user_id=$userId"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> historyData = data['history'];
        return historyData.map((item) => MessageItem.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load history: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching history: $e");
    }
  }
}