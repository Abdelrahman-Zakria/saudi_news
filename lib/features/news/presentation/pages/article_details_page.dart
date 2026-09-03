import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../domain/entities/article.dart';
import '../../../../core/widgets/app_video_player.dart';
import '../../../../core/widgets/app_article_image.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../widgets/small_news_card.dart';

class ArticleDetailsPage extends StatelessWidget {
  final Article article;

  const ArticleDetailsPage({super.key, required this.article});

  void _shareArticle(BuildContext context) {
    final String text = "${article.title}\n\n${article.excerpt}\n\n"
        "تابع المزيد عبر تطبيق أخبار السعودية:\n"
        "${Platform.isAndroid ? 'https://play.google.com/store/apps/details?id=com.saudi.news' : 'https://apps.apple.com/app/id123456789'}";
    
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saudiGreen = const Color(0xFF006C35);
    final repository = NewsRepositoryImpl();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Professional Sticky Header with Background
            SliverAppBar(
              expandedHeight: article.videoUrl != null ? 350 : 500, // Taller for images
              pinned: true,
              stretch: true,
              backgroundColor: isDark ? const Color(0xFF0D1117) : saudiGreen,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.4),
                    child: IconButton(
                      icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                      onPressed: () => _shareArticle(context),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (article.videoUrl != null)
                      AppVideoPlayer(
                        key: ValueKey(article.videoUrl),
                        videoUrl: article.videoUrl!,
                        thumbnailUrl: article.img,
                      )
                    else
                      Hero(
                        tag: 'article_${article.id}',
                        child: AppArticleImage(
                          imageUrl: article.img,
                          fit: BoxFit.contain, // Show full image without cropping
                        ),
                      ),
                    
                    // Soft Overlay - Only for images to not block video controls
                    if (article.videoUrl == null)
                      const IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.black54,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Content Area
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Professional Metadata Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF006C35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            article.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 6),
                        Text(
                          intl.DateFormat('d MMMM yyyy', 'ar').format(article.createdAt),
                          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Headline
                    Text(
                      article.title,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                        height: 1.3,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Refined Divider
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF006C35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Article Body
                    // SelectableText(
                    //   article.excerpt,
                    //   style: TextStyle(
                    //     fontSize: 18,
                    //     height: 1.9,
                    //     color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151),
                    //     fontFamily: 'Roboto', 
                    //   ),
                    // ),
                    
                    const SizedBox(height: 48),

                    // More News Section
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF006C35),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "أخبار أخرى قد تهمك",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<Article>>(
                      stream: repository.getNewsStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        
                        final moreNews = snapshot.data!
                            .where((a) => a.id != article.id)
                            .take(5)
                            .toList();

                        return Column(
                          children: moreNews.map((a) => SmallNewsCard(article: a)).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalStat(String emoji, String count, String label, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
