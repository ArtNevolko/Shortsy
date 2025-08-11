import 'dart:async';

class ChatMessage {
  final String id;
  final String author;
  final String text;
  final DateTime ts;
  ChatMessage(
      {required this.id,
      required this.author,
      required this.text,
      DateTime? ts})
      : ts = ts ?? DateTime.now();
}

class ChatService {
  static final ChatService _i = ChatService._();
  ChatService._();
  factory ChatService() => _i;

  final _controller = StreamController<List<ChatMessage>>.broadcast();
  final List<ChatMessage> _messages = [];

  Stream<List<ChatMessage>> get stream => _controller.stream;

  void send(String author, String text) {
    final msg = ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        author: author,
        text: text);
    _messages.add(msg);
    _controller.add(List.unmodifiable(_messages));
  }

  void dispose() {
    _controller.close();
  }
}
