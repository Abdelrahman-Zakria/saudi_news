class Article {
  final String id;
  final String category;
  final String title;
  final String source;
  final DateTime createdAt;
  final String twitterDate;
  final String engagement;
  final String img;
  final String excerpt;
  final List<String> tags;
  final List<String> mediaUrls;
  final String? videoUrl;
  final int likeCount;
  final int retweetCount;
  final int replyCount;

  Article({
    required this.id,
    required this.category,
    required this.title,
    required this.source,
    required this.createdAt,
    required this.twitterDate,
    required this.engagement,
    required this.img,
    required this.excerpt,
    required this.tags,
    this.mediaUrls = const [],
    this.videoUrl,
    this.likeCount = 0,
    this.retweetCount = 0,
    this.replyCount = 0,
  });
}
