import 'package:flutter/material.dart';
import '../../models/comment.dart';
import '../../services/api_client.dart';
import '../../services/comment_service.dart';

class CommentsSheet extends StatefulWidget {
  final String itemId;
  const CommentsSheet({super.key, required this.itemId});
  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _tc = TextEditingController();
  late final CommentService _svc =
      CommentService(const ApiClient('https://api.shortsy.local'));
  List<Comment> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _svc.list(widget.itemId);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _send() async {
    final t = _tc.text.trim();
    if (t.isEmpty) return;
    _tc.clear();
    final added = await _svc.add(widget.itemId, t);
    if (!mounted) return;
    setState(() {
      _items.insert(0, added);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(children: [
          const SizedBox(height: 8),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 8),
          const Text('Комментарии',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 12),
                itemCount: _items.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Colors.white10),
                itemBuilder: (context, i) {
                  final c = _items[i];
                  return ListTile(
                    leading:
                        const CircleAvatar(backgroundColor: Colors.white24),
                    title: Text(c.author,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                    subtitle: Text(c.text,
                        style: const TextStyle(color: Colors.white70)),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _tc,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Добавить комментарий...',
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
        ]),
      ),
    );
  }
}
