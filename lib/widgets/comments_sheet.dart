import 'package:flutter/material.dart';
import '../widgets/glass.dart';
import '../services/comments_service.dart';

class CommentsSheet extends StatefulWidget {
  final String postId;
  const CommentsSheet({super.key, required this.postId});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _c = TextEditingController();
  late Future<List<String>> _future;

  @override
  void initState() {
    super.initState();
    _future = CommentsService().getAll(widget.postId);
  }

  Future<void> _send() async {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    await CommentsService().add(widget.postId, t);
    _c.clear();
    setState(() => _future = CommentsService().getAll(widget.postId));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: FutureBuilder<List<String>>(
        future: _future,
        builder: (context, snap) {
          final items = snap.data ?? const <String>[];
          return SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: items.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                              radius: 14, backgroundColor: Colors.white24),
                          const SizedBox(width: 8),
                          Expanded(child: Text(items[i])),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Glass(
                          borderRadius: BorderRadius.circular(22),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: _c,
                            decoration: const InputDecoration(
                                hintText: 'Ваш комментарий',
                                border: InputBorder.none),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
