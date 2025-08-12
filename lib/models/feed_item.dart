class FeedItem {
  final String id;
  final String url;
  final String author;
  final String caption;
  final String sound;
  final int likes;
  final int comments;
  final int saves;
  final int shares;
  const FeedItem({
    required this.id,
    required this.url,
    required this.author,
    required this.caption,
    required this.sound,
    required this.likes,
    required this.comments,
    required this.saves,
    required this.shares,
  });

  factory FeedItem.mock(int i) => FeedItem(
        id: 'item_$i',
        url:
            'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        author: 'creator_$i',
        caption:
            'Потрясающий танец под новую популярную песню! #танцы #тренды #музыка',
        sound: 'Original Sound - creator_$i',
        likes: 245,
        comments: 12,
        saves: 61,
        shares: 8,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'author': author,
        'caption': caption,
        'sound': sound,
      };
  factory FeedItem.fromJson(Map<String, dynamic> j) => FeedItem(
        id: j['id'] as String,
        url: j['url'] as String,
        author: j['author'] as String? ?? '',
        caption: j['caption'] as String? ?? '',
        sound: j['sound'] as String? ?? '',
        likes: 0,
        comments: 0,
        saves: 0,
        shares: 0,
      );
}
