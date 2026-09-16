import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../domain/entities/job.dart';
import '../../../../core/widgets/app_video_player.dart';
import '../../../../core/widgets/app_article_image.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../widgets/job_card.dart';
import '../../../../core/services/ad_service.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Show ad when job details is opened
    AdService().showInterstitialAd();
  }

  void _shareJob(BuildContext context) {
    final String text = "${widget.job.title}\n\n${widget.job.description}\n\n"
        "تابع المزيد من الوظائف عبر تطبيق أخبار السعودية:\n"
        "${Platform.isAndroid ? 'https://play.google.com/store/apps/details?id=com.saudi.news' : 'https://apps.apple.com/app/id123456789'}";
    
    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saudiGreen = const Color(0xFF006C35);
    final repository = JobRepositoryImpl();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D1117) : Colors.white,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: widget.job.videoUrl != null ? 350 : 500, 
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
                      onPressed: () => _shareJob(context),
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
                    if (widget.job.videoUrl != null)
                      AppVideoPlayer(
                        key: ValueKey(widget.job.videoUrl),
                        videoUrl: widget.job.videoUrl!,
                        thumbnailUrl: widget.job.logo,
                      )
                    else if (widget.job.mediaUrls.isNotEmpty)
                      Hero(
                        tag: 'job_${widget.job.id}',
                        child: AppArticleImage(
                          imageUrl: widget.job.mediaUrls.first,
                          fit: BoxFit.contain, 
                        ),
                      )
                    else
                      Hero(
                        tag: 'job_${widget.job.id}',
                        child: Center(
                          child: Icon(Icons.business, size: 100, color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                    
                    if (widget.job.videoUrl == null)
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

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF006C35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.job.category,
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
                                intl.DateFormat('d MMMM yyyy - hh:mm a', 'ar').format(widget.job.createdAt),
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

                    Text(
                      widget.job.title, 
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                        height: 1.4,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description text (Replaces specific rows)
                    Text(
                      widget.job.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey[300] : Colors.black87,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 48),

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
                          "وظائف أخرى قد تهمك",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Job>>(
                      future: repository.getJobs(limit: 5),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        
                        final moreJobs = snapshot.data!
                            .where((j) => j.id != widget.job.id)
                            .toList();

                        return Column(
                          children: moreJobs.map((j) => JobCard(job: j)).toList(),
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
