import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/tech_news_cubit.dart';
import '../cubit/news_cubit.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          child: BlocBuilder<TechNewsCubit, NewsState>(
            builder: (context, state) {
              if (state is NewsLoading) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
              }

              if (state is NewsLoaded) {
                final techArticles = state.allArticles; // No filtering needed if coming from 'technology' collection

                if (techArticles.isEmpty) {
                  return const Center(child: Text("لا توجد أخبار تقنية حالياً", style: TextStyle(color: Color(0xFF9CA3AF))));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: techArticles.length + (state.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == techArticles.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF006C35))),
                      );
                    }
                    return SmallNewsCard(
                      article: techArticles[index],
                      isFavorite: false,
                      onFavorite: () {},
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
}
