import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resilify/services/message_item.dart';


class MessageHistoryScreen extends StatefulWidget {
  final int userId;

  const MessageHistoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _MessageHistoryScreenState createState() => _MessageHistoryScreenState();
}

class _MessageHistoryScreenState extends State<MessageHistoryScreen> {
  // API URL - change this to your server address
  final String baseUrl = 'http://82.29.162.82:5000';

  // UI state management
  bool isLoading = true;
  bool isEditing = false;
  int? editingMessageId;

  // Message data
  List<MessageItem> messages = [];

  // Controllers for editing
  final TextEditingController userInputController = TextEditingController();
  final TextEditingController aiResponseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMessageHistory();
  }

  // Fetch message history for the current user
  Future<void> fetchMessageHistory() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history?user_id=${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> historyData = data['history'];

        setState(() {
          messages = historyData.map((item) => MessageItem.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        showSnackBar('Failed to load history');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      showSnackBar('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Update a message
  Future<void> updateMessage(int messageId, String userInput, String aiResponse) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/message/$messageId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_input': userInput,
          'ai_response': aiResponse,
        }),
      );

      if (response.statusCode == 200) {
        showSnackBar('Message updated successfully');
        fetchMessageHistory();
      } else {
        showSnackBar('Failed to update message');
      }
    } catch (e) {
      showSnackBar('Error: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(int messageId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/message/$messageId'),
      );

      if (response.statusCode == 200) {
        showSnackBar('Message deleted successfully');
        fetchMessageHistory();
      } else {
        showSnackBar('Failed to delete message');
      }
    } catch (e) {
      showSnackBar('Error: $e');
    }
  }

  // Reset conversation for this user
  Future<void> resetConversation() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId,
        }),
      );

      if (response.statusCode == 200) {
        showSnackBar('Conversation reset successfully');
      } else {
        showSnackBar('Failed to reset conversation');
      }
    } catch (e) {
      showSnackBar('Error: $e');
    }
  }

  // Show snackbar message
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Start editing a message
  void startEditing(MessageItem message) {
    setState(() {
      isEditing = true;
      editingMessageId = message.id;
      userInputController.text = message.userInput;
      aiResponseController.text = message.aiResponse;
    });
  }

  // Cancel editing
  void cancelEditing() {
    setState(() {
      isEditing = false;
      editingMessageId = null;
      userInputController.clear();
      aiResponseController.clear();
    });
  }

  // Save edited message
  void saveEditing() {
    if (editingMessageId != null) {
      updateMessage(
        editingMessageId!,
        userInputController.text,
        aiResponseController.text,
      );
      setState(() {
        isEditing = false;
        editingMessageId = null;
      });
    }
  }

  // Show delete confirmation dialog
  void showDeleteConfirmation(int messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteMessage(messageId);
              },
              child: const Text('DELETE'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  // Show reset confirmation dialog
  void showResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Conversation'),
          content: const Text('This will clear the AI\'s memory of your conversation. Your message history will still be available. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetConversation();
              },
              child: const Text('RESET'),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History - User ${widget.userId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchMessageHistory,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: showResetConfirmation,
            tooltip: 'Reset Conversation',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isEditing
          ? buildEditForm()
          : buildMessageList(),
    );
  }

  // Build edit form
  Widget buildEditForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Edit Message #$editingMessageId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: userInputController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'User Input',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: aiResponseController,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'AI Response',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: cancelEditing,
                child: const Text('CANCEL'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: saveEditing,
                child: const Text('SAVE'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build message list
  Widget buildMessageList() {
    if (messages.isEmpty) {
      return const Center(
        child: Text('No messages found for this user'),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchMessageHistory,
      child: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => startEditing(message),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () => showDeleteConfirmation(message.id),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                  const Divider(),
                  Text('User Input:',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 8),
                  Text(message.userInput),
                  const SizedBox(height: 16),
                  Text('AI Response:',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 8),
                  Text(message.aiResponse),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    userInputController.dispose();
    aiResponseController.dispose();
    super.dispose();
  }
}