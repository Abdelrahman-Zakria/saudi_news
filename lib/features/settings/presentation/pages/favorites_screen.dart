import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../news/presentation/cubit/favorites_cubit.dart';
import '../../../news/presentation/cubit/favorites_state.dart';
import '../../../news/presentation/widgets/news_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('المفضلة', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black,
        ),
        body: SafeArea(
          child: BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              if (state is FavoritesLoaded) {
                final favorites = state.favoriteArticles;
                
                if (favorites.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    // Add section header for the first item
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(theme, "مجموعتك المحفوظة"),
                          const SizedBox(height: 16),
                          NewsCard(article: favorites[index]),
                        ],
                      );
                    }
                    return NewsCard(article: favorites[index]);
                  },
                );
              }
              return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF006C35),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
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
