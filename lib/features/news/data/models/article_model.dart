import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/article.dart';

class ArticleModel extends Article {
  ArticleModel({
    required super.id,
    required super.category,
    required super.title,
    required super.source,
    required super.createdAt,
    required super.twitterDate,
    required super.engagement,
    required super.img,
    required super.excerpt,
    required super.tags,
    super.mediaUrls,
    super.videoUrl,
    super.likeCount,
    super.retweetCount,
    super.replyCount,
  });

  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Extract media and determine video URL
    final mediaList = data['media'] as List<dynamic>? ?? [];
    final mediaUrls = <String>[];
    String? videoUrl;

    for (final m in mediaList) {
      final map = m as Map<String, dynamic>;
      final thumb = map['media_url_https'] as String?;
      if (thumb != null) mediaUrls.add(thumb);

      // Check for video
      if (map['type'] == 'video' || map['type'] == 'animated_gif') {
        final videoInfo = map['video_info'] as Map<String, dynamic>?;
        if (videoInfo != null) {
          final variants = videoInfo['variants'] as List<dynamic>? ?? [];
          // Try to find the best MP4 variant
          String? bestMp4;
          int maxBitrate = -1;
          
          for (final v in variants) {
            final variant = v as Map<String, dynamic>;
            if (variant['content_type'] == 'video/mp4') {
              final bitrate = variant['bitrate'] as int? ?? 0;
              if (bitrate > maxBitrate) {
                maxBitrate = bitrate;
                bestMp4 = variant['url'] as String?;
              }
            }
          }
          videoUrl = bestMp4;
        }
      }
    }

    final String rawText = data['text'] as String? ?? '';
    
    // 1. STRIP ALL LINKS (http/https)
    final String textWithoutLinks = rawText.replaceAll(RegExp(r'https?://[^\s]+'), '').trim();

    // 2. COLLAPSE ALL vertical spacing: Replace all newlines with spaces and condense multiple spaces
    final String cleanText = textWithoutLinks.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

    // 2. PARSE Title
    // Use the full clean text as the title (up to a reasonable length for lists)
    // but keep everything in the body
    String title = cleanText;
    if (title.length > 80) {
      title = "${title.substring(0, 80)}...";
    }


    // 3. Fallback: If title is still too short, take a chunk of the text
    if (title.length < 10 && cleanText.length > 10) {
      title = cleanText.substring(0, cleanText.length > 50 ? 50 : cleanText.length).replaceAll('\n', ' ');
    }

    final createdAt = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final twitterDate = data['createdAt'] as String? ?? '';
    
    // Engagement formatting
    final likes = data['likeCount'] as int? ?? 0;
    final retweets = data['retweetCount'] as int? ?? 0;
    final totalEngagement = likes + retweets;
    final engagementStr = totalEngagement > 1000 
        ? '${(totalEngagement / 1000).toStringAsFixed(1)}k' 
        : totalEngagement.toString();

    final category = data['category'] as String? ?? 'عام';

    return ArticleModel(
      id: data['tweetId'] as String? ?? doc.id,
      category: category,
      title: title.trim(),
      source: data['author'] as String? ?? 'غير معروف',
      createdAt: createdAt,
      twitterDate: twitterDate,
      engagement: engagementStr,
      img: mediaUrls.isNotEmpty ? mediaUrls.first : 'assets/appIconNew.jpeg',
      excerpt: cleanText,
      tags: [category],
      mediaUrls: mediaUrls,
      videoUrl: videoUrl,
      likeCount: likes,
      retweetCount: retweets,
      replyCount: data['replyCount'] as int? ?? 0,
    );
  }

  factory ArticleModel.fromJson(Map<String, dynamic> data) {
    final mediaList = data['media'] as List<dynamic>? ?? [];
    final mediaUrls = <String>[];

    for (final m in mediaList) {
      final map = m as Map<String, dynamic>;
      final thumb = map['media_url_https'] as String?;
      if (thumb != null) mediaUrls.add(thumb);
    }

    DateTime createdAt;
    if (data['timestamp'] is Timestamp) {
      createdAt = (data['timestamp'] as Timestamp).toDate();
    } else if (data['timestamp'] is String) {
      createdAt = DateTime.parse(data['timestamp']);
    } else {
      createdAt = DateTime.now();
    }

    return ArticleModel(
      id: data['tweetId'] ?? data['id'] ?? '',
      category: data['category'] ?? 'عام',
      title: (data['text'] as String? ?? '').split('\n').first,
      source: data['author'] ?? 'غير معروف',
      createdAt: createdAt,
      twitterDate: data['createdAt'] ?? '',
      engagement: data['engagement'] ?? '0',
      img: mediaUrls.isNotEmpty ? mediaUrls.first : 'assets/appIconNew.jpeg',
      excerpt: data['text'] ?? '',
      tags: [data['category'] ?? 'عام'],
      mediaUrls: mediaUrls,
      videoUrl: data['videoUrl'],
      likeCount: data['likeCount'] ?? 0,
      retweetCount: data['retweetCount'] ?? 0,
      replyCount: data['replyCount'] ?? 0,
    );
  }
}
