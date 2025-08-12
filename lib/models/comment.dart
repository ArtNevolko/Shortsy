class Comment {
  final String id;
  final String author;
  final String text;
  final int ts;
  Comment(
      {required this.id,
      required this.author,
      required this.text,
      required this.ts});
  factory Comment.fromJson(Map<String, dynamic> j) => Comment(
        id: j['id'] as String,
        author: j['author'] as String? ?? '',
        text: j['text'] as String? ?? '',
        ts: (j['ts'] as num?)?.toInt() ?? 0,
      );
}
