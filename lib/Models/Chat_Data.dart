class ChatMessage {
  final String sender;
  final String text;
  final String time;
  final bool options;

  ChatMessage(
      {required this.sender,
      required this.text,
      required this.time,
      this.options = false});
}
