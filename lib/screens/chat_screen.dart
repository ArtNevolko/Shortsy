import 'package:flutter/material.dart';
import '../shared/widgets/index.dart';

class ChatScreen extends StatefulWidget {
  final String title;
  const ChatScreen({super.key, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_Msg> _messages = [
    _Msg(text: 'Привет! Это демо-диалог.', me: false),
    _Msg(text: 'Готовлю глобальный редизайн 🤝', me: true),
    _Msg(text: 'Проверяй обновления экранов.', me: true),
  ];
  final TextEditingController _c = TextEditingController();
  final ScrollController _s = ScrollController();

  void _send() {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: t, me: true));
    });
    _c.clear();
    Future.delayed(
        const Duration(milliseconds: 50),
        () => _s.animateTo(
              _s.position.maxScrollExtent + 80,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            ));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return AppScaffold(
      title: widget.title,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _s,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final align =
                    m.me ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                final radius = BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(m.me ? 20 : 4),
                  bottomRight: Radius.circular(m.me ? 4 : 20),
                );
                return Column(
                  crossAxisAlignment: align,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Glass(
                          borderRadius: radius,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          tint: m.me ? Colors.white : Colors.lightBlueAccent,
                          opacity: m.me ? 0.08 : 0.10,
                          child: Text(m.text),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(bottom: 12 + bottom),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Glass(
                      borderRadius: BorderRadius.circular(24),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _c,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Сообщение...',
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _send,
                    borderRadius: BorderRadius.circular(22),
                    child: Glass(
                      borderRadius: BorderRadius.circular(22),
                      padding: const EdgeInsets.all(10),
                      child: const Icon(Icons.send_rounded, size: 20),
                    ),
                  )
                ],
              ),
            ),
          )
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
