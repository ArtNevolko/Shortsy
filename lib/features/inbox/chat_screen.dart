import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String title;
  const ChatScreen({super.key, required this.title});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_Msg> _messages = [
    _Msg(text: 'Привет!', me: false),
    _Msg(text: 'Привет, как дела?', me: true),
  ];
  final TextEditingController _tc = TextEditingController();

  void _send() {
    final t = _tc.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: t, me: true));
    });
    _tc.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return Align(
                  alignment:
                      m.me ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: m.me ? const Color(0xFF6C5CE7) : Colors.white12,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(m.text,
                        style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _tc,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Сообщение...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send, color: Colors.white)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool me;
  _Msg({required this.text, required this.me});
}
