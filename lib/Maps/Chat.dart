import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatbotService {
  final Dio _dio = Dio();
  static const String baseUrl =
      "https://jagavantha-safora.hf.space/gradio_api/call/predict";

  Future<String> getChatbotResponse(String message) async {
    try {
      // POST request to initiate conversation
      final Response postResponse = await _dio.post(
        baseUrl,
        options: Options(headers: {"Content-Type": "application/json"}),
        data: {
          "data": [message]
        },
      );

      if (postResponse.statusCode != 200 ||
          !postResponse.data.containsKey("event_id")) {
        throw Exception("Invalid API response structure");
      }

      final String eventId = postResponse.data["event_id"];
      await Future.delayed(const Duration(seconds: 1));

      // GET request to fetch response
      final Response getResponse = await _dio.get(
        "$baseUrl/$eventId",
        options: Options(responseType: ResponseType.plain),
      );

      // Parse SSE response
      final String responseBody = getResponse.data.toString();
      final List<String> lines = responseBody.split('\n');

      String dataLine = lines.firstWhere(
        (line) => line.startsWith('data: '),
        orElse: () => '',
      );

      if (dataLine.isEmpty) {
        throw Exception("No data found in response");
      }

      // Extract and parse JSON data
      final String jsonString = dataLine.substring(5).trim();
      final dynamic jsonData = json.decode(jsonString);

      if (jsonData is! List || jsonData.isEmpty) {
        throw Exception("Invalid response format");
      }

      return jsonData[0].toString().trim();
    } catch (e) {
      throw Exception("Failed to get response: ${e.toString()}");
    }
  }
}

class ChatMessage {
  final String sender;
  final String text;
  final String time;
  final bool isTyping;
  final String uniqueKey;

  const ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    this.isTyping = false,
    required this.uniqueKey,
  });
}

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ChatbotService _chatbotService = ChatbotService();
  bool _isBotTyping = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _addSystemMessage(
      'Hello! I am your accident hotspot prediction assistant. How can I help?',
    );
  }

  void _addSystemMessage(String text, {bool isTyping = false}) {
    _messages.add(ChatMessage(
      sender: 'System',
      text: text,
      time: _getCurrentTime(),
      isTyping: isTyping,
      uniqueKey: DateTime.now().millisecondsSinceEpoch.toString(),
    ));
    _scrollToBottom();
  }

  String _getCurrentTime() => DateFormat('HH:mm').format(DateTime.now());

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        sender: 'User',
        text: message,
        time: _getCurrentTime(),
        uniqueKey: DateTime.now().millisecondsSinceEpoch.toString(),
      ));
      _messageController.clear();
      _isBotTyping = true;
      _addSystemMessage('', isTyping: true);
    });

    try {
      final response = await _chatbotService.getChatbotResponse(message);

      setState(() {
        _isBotTyping = false;
        _messages.removeLast();
        _addSystemMessage(response);
      });
    } catch (e) {
      setState(() {
        _isBotTyping = false;
        _messages.removeLast();
        _addSystemMessage(
            "Sorry, I'm having trouble responding. Please try again.");
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _ChatHeader(),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.2),
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _ChatBubble(
                  key: ValueKey(_messages[index].uniqueKey),
                  message: _messages[index],
                ),
              ),
            ),
          ),
          _ChatInput(
            controller: _messageController,
            onSend: _sendMessage,
            isBotTyping: _isBotTyping,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.support_agent,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(width: 12),
        Text(
          'Accident Assistant',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({
    required Key key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == 'User';
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.engineering, size: 18, color: Colors.blue),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  if (!message.isTyping)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                ],
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: message.isTyping
                  ? const TypingIndicator()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            fontSize: 16,
                            color: isUser
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: (isUser
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurfaceVariant)
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 18, color: Colors.green),
            ),
          ],
        ],
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Interval> _dotIntervals = const [
    Interval(0.0, 0.3),
    Interval(0.2, 0.5),
    Interval(0.4, 0.7),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _dotIntervals[index]
                  .transform(_animationController.value)
                  .clamp(0.0, 1.0),
              child: child,
            );
          },
          child: Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isBotTyping;
  final ValueChanged<String>? onChanged;

  const _ChatInput({
    required this.controller,
    required this.onSend,
    required this.isBotTyping,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = controller.text.trim().isEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                suffixIcon: isBotTyping
                    ? const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              maxLines: 3,
              minLines: 1,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: isEmpty ? null : onSend,
            backgroundColor:
                isEmpty ? Colors.grey : Theme.of(context).colorScheme.primary,
            elevation: 0,
            shape: const CircleBorder(),
            child: Icon(
              Icons.send_rounded,
              color: isEmpty
                  ? Colors.grey[400]
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
