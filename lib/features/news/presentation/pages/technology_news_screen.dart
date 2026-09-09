import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/tech_news_cubit.dart';
import '../cubit/news_state.dart';
import '../widgets/small_news_card.dart';

class TechnologyNewsScreen extends StatefulWidget {
  const TechnologyNewsScreen({super.key});

  @override
  State<TechnologyNewsScreen> createState() => _TechnologyNewsScreenState();
}

class _TechnologyNewsScreenState extends State<TechnologyNewsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<TechNewsCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('أخبار التقنية', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black,
        ),
        body: SafeArea(
          child: BlocBuilder<TechNewsCubit, NewsState>(
            builder: (context, state) {
              if (state is NewsLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
              }

              if (state is NewsLoaded) {
                final techArticles = state.allArticles; 

                if (techArticles.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: techArticles.length + (state.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == techArticles.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF006C35))),
                      );
                    }

                    // Add section header for the first item
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(theme, "أحدث المستجدات التقنية"),
                          const SizedBox(height: 16),
                          SmallNewsCard(article: techArticles[index]),
                        ],
                      );
                    }

                    return SmallNewsCard(
                      article: techArticles[index],
                    );
                  },
                );
              }
              
              if (state is NewsError) {
                return Center(child: Text(state.message));
              }

              return const SizedBox.shrink();
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.computer_outlined, size: 64, color: Color(0xFF9CA3AF)),
          SizedBox(height: 16),
          Text(
            "لا توجد أخبار تقنية حالياً",
            style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
