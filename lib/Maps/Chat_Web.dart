import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

// Custom theme colors
class AppColors {
  static const primary = Color(0xFF006D77);
  static const secondary = Color(0xFF83C5BE);
  static const background = Color(0xFFF8F9FA);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF2B2D42);
  static const textSecondary = Color(0xFF6C757D);
  static const accent = Color(0xFFE29578);
}

// Chat history model
class ChatHistory {
  final String title;
  String lastMessage;
  final String date;
  final String category; // Added category for professional organization
  final List<ChatMessage> messages;

  ChatHistory({
    required this.title,
    required this.lastMessage,
    required this.date,
    required this.messages,
    required this.category,
  });
}

// Rest of the service remains the same
class ChatbotService {
  final Dio _dio = Dio();
  static const String baseUrl =
      "https://jagavantha-safora.hf.space/gradio_api/call/predict";

  Future<String> getChatbotResponse(String message) async {
    try {
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

      final Response getResponse = await _dio.get(
        "$baseUrl/$eventId",
        options: Options(responseType: ResponseType.plain),
      );

      final String responseBody = getResponse.data.toString();
      final List<String> lines = responseBody.split('\n');

      String dataLine = lines.firstWhere(
        (line) => line.startsWith('data: '),
        orElse: () => '',
      );

      if (dataLine.isEmpty) {
        throw Exception("No data found in response");
      }

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

class ChatBotScreenWeb extends StatefulWidget {
  const ChatBotScreenWeb({super.key});

  @override
  State<ChatBotScreenWeb> createState() => _ChatBotScreenWebState();
}

class _ChatBotScreenWebState extends State<ChatBotScreenWeb> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final List<ChatHistory> _chatHistory = [];
  final ChatbotService _chatbotService = ChatbotService();
  final ScrollController _scrollController = ScrollController();
  int _selectedHistoryIndex = -1;
  ChatHistory? _currentChatHistory;

  @override
  void initState() {
    super.initState();
    _addSystemMessage(
      'Welcome to the Accident Hotspot Analysis System. How may I assist you today?',
    );
    _initializeProfessionalHistory();
  }

  void _initializeProfessionalHistory() {
    _chatHistory.addAll([
      ChatHistory(
        title: 'High-Risk Zone Analysis',
        lastMessage:
            'Comprehensive analysis of accident-prone areas in Route 66',
        date: '2024-02-15',
        category: 'Risk Assessment',
        messages: [
          ChatMessage(
            sender: 'System',
            text: 'Analysis completed for Route 66 high-risk zones',
            time: '09:30',
            uniqueKey: '1',
          ),
        ],
      ),
      ChatHistory(
        title: 'Traffic Pattern Report',
        lastMessage: 'Downtown intersection traffic flow analysis completed',
        date: '2024-02-14',
        category: 'Traffic Analysis',
        messages: [
          ChatMessage(
            sender: 'System',
            text: 'Traffic pattern analysis for downtown area completed',
            time: '14:20',
            uniqueKey: '2',
          ),
        ],
      ),
      ChatHistory(
        title: 'Safety Measures Implementation',
        lastMessage: 'Recommended safety measures for identified hotspots',
        date: '2024-02-13',
        category: 'Safety Planning',
        messages: [
          ChatMessage(
            sender: 'System',
            text: 'Safety measures implementation plan generated',
            time: '11:45',
            uniqueKey: '3',
          ),
        ],
      ),
    ]);
  }

  void _addSystemMessage(String text, {bool isTyping = false}) {
    setState(() {
      _messages.add(ChatMessage(
        sender: 'System',
        text: text,
        time: _getCurrentTime(),
        isTyping: isTyping,
        uniqueKey: DateTime.now().millisecondsSinceEpoch.toString(),
      ));
    });
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
      _addSystemMessage('', isTyping: true);
    });

    try {
      final response = await _chatbotService.getChatbotResponse(message);

      setState(() {
        _messages.removeLast();
        _addSystemMessage(response);

        // Update current chat history
        if (_currentChatHistory == null) {
          _currentChatHistory = ChatHistory(
            title:
                'Analysis Session ${DateFormat('MMM d, y').format(DateTime.now())}',
            lastMessage: message,
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            category: _determineChatCategory(message),
            messages: List.from(_messages),
          );
          _chatHistory.insert(0, _currentChatHistory!);
        } else {
          _currentChatHistory!.lastMessage = message;
          _currentChatHistory!.messages.addAll(_messages);
        }
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _addSystemMessage(
          "I apologize, but I'm experiencing technical difficulties. Please try again.",
        );
      });
    }
  }

  String _determineChatCategory(String message) {
    // Simple category determination based on message content
    message = message.toLowerCase();
    if (message.contains('risk') || message.contains('danger')) {
      return 'Risk Assessment';
    } else if (message.contains('traffic') || message.contains('flow')) {
      return 'Traffic Analysis';
    } else if (message.contains('safety') || message.contains('prevent')) {
      return 'Safety Planning';
    }
    return 'General Inquiry';
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

  void _loadChatHistory(int index) {
    setState(() {
      _selectedHistoryIndex = index;
      _messages.clear();
      _messages.addAll(_chatHistory[index].messages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                    ),
                    child: _buildChatArea(),
                  ),
                ),
                _buildInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          Expanded(
            child: ListView.builder(
              itemCount: _chatHistory.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) => _buildHistoryItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.history_rounded, color: AppColors.surfaceLight, size: 28),
          const SizedBox(width: 12),
          Text(
            'Conversation History',
            style: GoogleFonts.inter(
              color: AppColors.surfaceLight,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(int index) {
    final history = _chatHistory[index];
    final isSelected = index == _selectedHistoryIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          history.title,
          style: GoogleFonts.inter(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                history.category,
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              history.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              history.date,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${history.messages.length} msgs',
                style: GoogleFonts.inter(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _loadChatHistory(index),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.analytics_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Accident Hotspot Analysis',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Assistant Online',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) => _ChatBubble(
        key: ValueKey(_messages[index].uniqueKey),
        message: _messages[index],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message here...',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
                prefixIcon: Icon(
                  Icons.message_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 16),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _messageController,
      builder: (context, value, child) {
        final bool isEnabled = value.text.trim().isNotEmpty;
        return GestureDetector(
          onTap: isEnabled ? _sendMessage : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEnabled
                  ? AppColors.primary
                  : AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.send_rounded,
              color: AppColors.surfaceLight,
              size: 24,
            ),
          ),
        );
      },
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _buildAvatar(isUser),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surfaceLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isTyping)
                    _buildTypingIndicator()
                  else
                    Text(
                      message.text,
                      style: GoogleFonts.inter(
                        color: isUser
                            ? AppColors.surfaceLight
                            : AppColors.textPrimary,
                        // ... previous code ...

                        fontSize: 16,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    message.time,
                    style: GoogleFonts.inter(
                      color: isUser
                          ? AppColors.surfaceLight.withOpacity(0.8)
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            _buildAvatar(isUser),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUser ? AppColors.primary : AppColors.secondary,
      ),
      child: CircleAvatar(
        backgroundColor: isUser
            ? AppColors.primary.withOpacity(0.2)
            : AppColors.secondary.withOpacity(0.2),
        radius: 18,
        child: Icon(
          isUser ? Icons.person : Icons.support_agent,
          color: isUser ? AppColors.primary : AppColors.secondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDot(1),
        _buildDot(2),
        _buildDot(3),
      ],
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(
              (value + 0.3 * index) % 1.0,
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
