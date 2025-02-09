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

class ChatBotScreenWeb extends StatefulWidget {
  const ChatBotScreenWeb({super.key});

  @override
  _ChatBotScreenWebState createState() => _ChatBotScreenWebState();
}

class _ChatBotScreenWebState extends State<ChatBotScreenWeb> {
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
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Determine if it's a web layout based on screen width
          bool isWebLayout = constraints.maxWidth > 600;

          return Row(
            children: [
              // Sidebar with chat history
              if (isWebLayout)
                SizedBox(
                  width: 250, // Adjust width as needed
                  child: Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chat History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              return _buildSidebarChatItem(_messages[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Main chat area
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildChatMessage(
                              _messages[index], isWebLayout);
                        },
                      ),
                    ),
                    _buildChatInput(isWebLayout),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget for displaying chat items in the sidebar
  Widget _buildSidebarChatItem(ChatMessage message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
      ),
      margin: const EdgeInsets.only(bottom: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.sender,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            message.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message, bool isWebLayout) {
    final isBotMessage = message.sender == 'System';
    double horizontalPadding = isWebLayout ? 16 : 8;
    double verticalMargin = isWebLayout ? 8 : 4;
    double borderRadiusValue = isWebLayout ? 12 : 10;
    double fontSize = isWebLayout ? 18 : 16;
    double timeFontSize = isWebLayout ? 14 : 12;

    return Align(
      alignment: isBotMessage ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.all(horizontalPadding),
        margin: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: verticalMargin),
        decoration: BoxDecoration(
          color: isBotMessage ? Colors.grey[200] : Colors.purple[300],
          borderRadius: BorderRadius.circular(borderRadiusValue),
        ),
        constraints: BoxConstraints(
          maxWidth: isWebLayout ? 600 : double.infinity,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                  fontSize: fontSize,
                  color: isBotMessage ? Colors.black : Colors.white),
            ),
            if (!message.options)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(message.time,
                      style: TextStyle(
                          fontSize: timeFontSize,
                          color:
                              isBotMessage ? Colors.black54 : Colors.white70)),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput(bool isWebLayout) {
    double inputPadding = isWebLayout ? 16 : 8;
    double iconSize = isWebLayout ? 30 : 24;

    return Container(
      padding: EdgeInsets.all(inputPadding),
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline,
              color: Colors.grey,
              size: iconSize,
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
            icon: Icon(
              Icons.send,
              color: Colors.purple,
              size: iconSize,
            ),
            onPressed: _sendMessage,
          )
        ],
      ),
    );
  }
}
