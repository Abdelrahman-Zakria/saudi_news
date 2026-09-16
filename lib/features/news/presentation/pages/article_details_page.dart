import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/article.dart';
import '../../../../core/widgets/app_video_player.dart';
import '../../../../core/widgets/app_article_image.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../widgets/small_news_card.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';
import '../../../../core/services/ad_service.dart';

class ArticleDetailsPage extends StatefulWidget {
  final Article article;

  const ArticleDetailsPage({super.key, required this.article});

  @override
  State<ArticleDetailsPage> createState() => _ArticleDetailsPageState();
}

class _ArticleDetailsPageState extends State<ArticleDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Show ad when article details is opened
    AdService().showInterstitialAd();
  }

  void _shareArticle(BuildContext context) {
    final String text = "${widget.article.title}\n\n${widget.article.excerpt}\n\n"
        "تابع المزيد عبر تطبيق أخبار السعودية:\n"
        "${Platform.isAndroid ? 'https://play.google.com/store/apps/details?id=com.saudi.news' : 'https://apps.apple.com/app/id123456789'}";
    
    SharePlus.instance.share(ShareParams(text: text));
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
              expandedHeight: widget.article.videoUrl != null ? 350 : 500, 
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
                  child: BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, state) {
                      final isFavorite = state.favoriteIds.contains(widget.article.id);
                      return CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.4),
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? const Color(0xFFDC2626) : Colors.white,
                            size: 20,
                          ),
                          onPressed: () => context.read<FavoritesCubit>().toggleFavorite(widget.article),
                        ),
                      );
                    },
                  ),
                ),
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
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.article.videoUrl != null)
                      AppVideoPlayer(
                        key: ValueKey(widget.article.videoUrl),
                        videoUrl: widget.article.videoUrl!,
                        thumbnailUrl: widget.article.img,
                      )
                    else
                      Hero(
                        tag: 'article_${widget.article.id}',
                        child: AppArticleImage(
                          imageUrl: widget.article.img,
                          fit: BoxFit.contain, 
                        ),
                      ),
                    
                    if (widget.article.videoUrl == null)
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
                            widget.article.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 6),
                              Text(
                                intl.DateFormat('d MMMM yyyy - hh:mm a', 'ar').format(widget.article.createdAt),
                                style: TextStyle(
                                  color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Headline - No Trimming, Full text allowed to wrap
                    Text(
                      widget.article.excerpt, 
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                        height: 1.4,
                        letterSpacing: -0.2,
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
                    FutureBuilder<List<Article>>(
                      future: repository.getNews(limit: 5),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        
                        final moreNews = snapshot.data!
                            .where((a) => a.id != widget.article.id)
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
}
