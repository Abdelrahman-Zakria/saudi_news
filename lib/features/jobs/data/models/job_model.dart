import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/job.dart';

class JobModel extends Job {
  const JobModel({
    required super.id,
    required super.title,
    required super.description,
    required super.author,
    required super.category,
    required super.createdAt,
    required super.twitterDate,
    required super.logo,
    super.urgent,
    super.mediaUrls,
    super.videoUrl,
    super.likeCount,
    super.retweetCount,
    super.replyCount,
  });

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
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
    String title = cleanText;
    if (title.length > 80) {
      title = "${title.substring(0, 80)}...";
    }

    if (title.length < 10 && cleanText.length > 10) {
      title = cleanText.substring(0, cleanText.length > 50 ? 50 : cleanText.length).replaceAll('\n', ' ');
    }

    final createdAt = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final twitterDate = data['createdAt'] as String? ?? '';
    
    final isUrgent = cleanText.contains('عاجل') || (data['category']?.toString().contains('عاجل') ?? false);
    
    return JobModel(
      id: data['tweetId'] as String? ?? doc.id,
      title: title.trim(),
      description: cleanText,
      author: data['author'] as String? ?? 'شركة سعودية',
      category: data['category'] as String? ?? 'وظائف',
      createdAt: createdAt,
      twitterDate: twitterDate,
      logo: mediaUrls.isNotEmpty ? mediaUrls.first : '💼',
      urgent: isUrgent,
      mediaUrls: mediaUrls,
      videoUrl: videoUrl,
      likeCount: data['likeCount'] as int? ?? 0,
      retweetCount: data['retweetCount'] as int? ?? 0,
      replyCount: data['replyCount'] as int? ?? 0,
    );
  }
}
