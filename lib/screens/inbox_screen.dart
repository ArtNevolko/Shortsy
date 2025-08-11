import 'package:flutter/material.dart';
import '../widgets/glass.dart';
import '../widgets/avatar_presence.dart';
import '../widgets/glass_header.dart';
import 'chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 88),
        children: [
          const GlassHeader(title: 'Messages', actions: [
            Icon(Icons.video_call_rounded),
            Icon(Icons.edit_rounded)
          ]),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text('Active Now',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          SizedBox(
            height: 92,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: const [
                AvatarPresence(
                    color: Color(0xFF7C83FD), label: 'User1', online: true),
                SizedBox(width: 12),
                AvatarPresence(
                    color: Color(0xFFF96D80), label: 'User2', online: true),
                SizedBox(width: 12),
                AvatarPresence(
                    color: Color(0xFF33BBC5), label: 'User3', online: true),
                SizedBox(width: 12),
                AvatarPresence(
                    color: Color(0xFF7DD3FC), label: 'User4', online: true),
                SizedBox(width: 12),
                AvatarPresence(
                    color: Color(0xFFA78BFA), label: 'User5', online: true),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text('Recent Chats',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          ...List.generate(8, (i) => _tile(context, i)),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, int i) {
    final colors = [
      const Color(0xFF7C83FD),
      const Color(0xFFF96D80),
      const Color(0xFF33BBC5),
      const Color(0xFF7DD3FC)
    ];
    final color = colors[i % colors.length];
    final name =
        ['Alex Johnson', 'Sarah Chen', 'Mike Wilson', 'Emma Davis'][i % 4];
    final msg = [
      'Love your latest video! 🔥',
      'Want to collaborate on a project?',
      'Thanks for the follow back!',
      'Your editing skills are amazing ✨'
    ][i % 4];
    final time = ['2m', '15m', '1h', '3h'][i % 4];
    final unread = i % 3 == 0 ? (i % 4) + 1 : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => ChatScreen(title: name))),
        child: Glass(
          borderRadius: BorderRadius.circular(22),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.9),
                  boxShadow: [
                    BoxShadow(
                        color: color.withValues(alpha: 0.5), blurRadius: 12)
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                            child: Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700))),
                        Text(time,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ]),
                      const SizedBox(height: 2),
                      Text(msg, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ]),
              ),
              if (unread > 0)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.9)),
                  child: Center(
                      child: Text('$unread',
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800))),
                )
            ],
          ),
        ),
      ),
    );
  }
}
