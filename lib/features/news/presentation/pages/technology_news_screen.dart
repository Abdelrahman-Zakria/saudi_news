import 'package:flutter/material.dart';
import '../../domain/entities/article.dart';
import '../../data/repositories/news_repository_impl.dart';
import '../widgets/small_news_card.dart';

class TechnologyNewsScreen extends StatelessWidget {
  const TechnologyNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final _repository = NewsRepositoryImpl();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('أخبار التقنية', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : Colors.black,
        ),
        body: SafeArea(
          child: StreamBuilder<List<Article>>(
            stream: _repository.getNewsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("لا توجد أخبار تقنية حالياً", style: TextStyle(color: Color(0xFF9CA3AF))));
              }

              // Filter for tech category
              final techArticles = snapshot.data!.where((a) => a.category == 'tech' || a.category == 'تقنية').toList();

              if (techArticles.isEmpty) {
                 return const Center(child: Text("لا توجد أخبار تقنية حالياً", style: TextStyle(color: Color(0xFF9CA3AF))));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: techArticles.length,
                itemBuilder: (context, index) {
                  return SmallNewsCard(
                    article: techArticles[index],
                    isFavorite: false, // In a real app, this would check a local DB/Cache
                    onFavorite: () {},
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
