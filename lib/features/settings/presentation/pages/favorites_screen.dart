import 'package:flutter/material.dart';
import 'package:saudi_news/features/news/domain/entities/article.dart';
import 'package:saudi_news/features/news/presentation/widgets/news_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for favorites - Updated to match new Article entity with twitterDate
    final List<Article> favoriteArticles = [
      Article(
        id: '1',
        category: 'ksa',
        title: 'المملكة تطلق أكبر مشروع طاقة شمسية في العالم بنيوم',
        source: 'العربية',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        twitterDate: 'Wed Sep 02 07:43:05 +0000 2026',
        engagement: '5.2k',
        img: 'assets/appIcon.jpeg',
        excerpt: 'أعلنت المملكة العربية السعودية عن إطلاق مشروع طاقة شمسية ضخم في منطقة نيوم بقدرة تتجاوز ١٠ جيجاوات.',
        tags: ['رؤية 2030', 'طاقة متجددة'],
      ),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('المفضلة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: SafeArea(
        child: favoriteArticles.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteArticles.length,
                itemBuilder: (context, index) {
                  return NewsCard(
                    article: favoriteArticles[index],
                    isFavorite: true,
                    onFavorite: () {
                      // Logic to remove from favorites
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("♡", style: TextStyle(fontSize: 64, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 16),
          const Text(
            'لا توجد مقالات مفضلة حالياً',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'قم بإضافة المقالات التي تعجبك للوصول إليها لاحقاً',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
