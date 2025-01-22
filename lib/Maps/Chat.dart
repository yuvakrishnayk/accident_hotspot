import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for time formatting

class ChatMessage {
  final String sender;
  final String text;
  final String time;
  final bool options;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    this.options = false,
  });
}

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      sender: 'System',
      text:
          'Hello! I am your accident hotspot prediction assistant. How can I help?',
      time: '1:40 PM',
    ),
  ];

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      setState(() {
        // Add the user's message
        _messages.add(ChatMessage(
          sender: 'User',
          text: messageText,
          time: _getCurrentTime(),
        ));

        // Add a response from the bot
        _messages.add(ChatMessage(
          sender: 'System',
          text: 'Acknowledged message received at: ${_getCurrentTime()}',
          time: _getCurrentTime(),
        ));
      });
      _messageController.clear(); // Clear the input
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return DateFormat('h:mm a').format(now); // Format the time
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.headset_mic_outlined,
                color: Colors.red,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Support',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildChatMessage(_messages[index]);
              },
            ),
          ),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    final isBotMessage = message.sender == 'System';

    return Align(
      alignment: isBotMessage ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isBotMessage ? Colors.grey[200] : Colors.purple[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                  fontSize: 16,
                  color: isBotMessage ? Colors.black : Colors.white),
            ),
            if (!message.options)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(message.time,
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              isBotMessage ? Colors.black54 : Colors.white70)),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.grey,
            ),
            onPressed: () {
              // Add attachment logic
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.send,
              color: Colors.purple,
            ),
            onPressed: _sendMessage,
          )
        ],
      ),
    );
  }
}
