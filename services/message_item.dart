class MessageItem {
  final int id;
  final int userId;
  final String userInput;
  final String aiResponse;
  final String timestamp;

  MessageItem({
    required this.id,
    required this.userId,
    required this.userInput,
    required this.aiResponse,
    required this.timestamp,
  });

  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      id: json['id'],
      userId: json['user_id'],
      userInput: json['user_input'],
      aiResponse: json['ai_response'],
      timestamp: json['timestamp'] ?? '',
    );
  }
}