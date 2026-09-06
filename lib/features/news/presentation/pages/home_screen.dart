import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../cubit/news_cubit.dart';
import '../cubit/news_state.dart';
import '../../domain/entities/article.dart';
import '../widgets/small_news_card.dart';
import '../widgets/category_pills.dart';
import '../widgets/breaking_ticker.dart';
import 'article_details_page.dart';
import '../../../../core/widgets/app_article_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _favorites = {};

  final List<CategoryItem> _sections = [
    CategoryItem(id: "all", label: "الكل"),
    CategoryItem(id: "سياسة", label: "⚖️ سياسة"),
    CategoryItem(id: "اقتصاد", label: "💼 اقتصاد"),
    CategoryItem(id: "مجتمع", label: "👥 مجتمع"),
    CategoryItem(id: "تكنولوجيا", label: "💻 تكنولوجيا"),
    CategoryItem(id: "رياضة", label: "⚽ رياضة"),
    CategoryItem(id: "عاجل", label: "🚨 عاجل"),
    CategoryItem(id: "عام", label: "🌍 عام"),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<NewsCubit>().searchNews(_searchController.text);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<NewsCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
      } else {
        _favorites.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        if (state is NewsLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
        }

        if (state is NewsError) {
          return Center(child: Text(state.message));
        }

        if (state is NewsLoaded) {
          final bool isSearching = state.searchQuery.isNotEmpty;
          final featured = state.allArticles.isNotEmpty ? state.allArticles.first : null;

          return Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              children: [
                _buildSearchBar(context),
                
                if (isSearching)
                  _buildSearchResults(state.filteredArticles, isDark, state.searchQuery)
                else ...[
                  BreakingTicker(articles: state.breakingNews),
                  if (featured != null) _buildFeaturedArticle(featured),
                  
                  CategoryPills(
                    categories: _sections,
                    activeCategoryId: state.activeCategory,
                    onCategorySelected: (id) {
                      context.read<NewsCubit>().changeCategory(id);
                    },
                  ),

                  _buildListContent(state, isDark, theme),
                  
                  if (state.hasMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF006C35))),
                    ),
                ],
                
                const SizedBox(height: 80),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFeaturedArticle(Article featured) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailsPage(article: featured),
                ),
              );
            },
            child: Container(
              height: 208,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppArticleImage(
                    imageUrl: featured.img,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  if (featured.videoUrl != null)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 48),
                      ),
                    ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: featured.tags.map((t) => Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF006C35),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 10)),
                          )).toList(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          featured.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('HH:mm').format(featured.createdAt),
                              style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: GestureDetector(
              onTap: () => _toggleFavorite(featured.id),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _favorites.contains(featured.id)
                      ? const Color(0xFF006C35)
                      : Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _favorites.contains(featured.id) ? "♥" : "♡",
                    style: TextStyle(
                      color: _favorites.contains(featured.id) ? Colors.white : const Color(0xFF4B5563),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(NewsLoaded state, bool isDark, ThemeData theme) {
    if (state.filteredArticles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(48.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.newspaper_outlined, size: 64, color: Color(0xFF9CA3AF)),
              SizedBox(height: 16),
              Text("لا توجد أخبار في هذا القسم حالياً", style: TextStyle(color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      );
    }

    final mostRead = state.allArticles.take(3).toList();
    final rest = state.filteredArticles;

    return Column(
      children: [
        if (state.activeCategory == "all")
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
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
                      "الأكثر قراءة",
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...mostRead.asMap().entries.map((entry) {
                  final i = entry.key;
                  final a = entry.value;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleDetailsPage(article: a),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "${i + 1}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: i == 0 ? const Color(0xFF006C35) : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.title,
                                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${a.engagement} قراءة",
                                  style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              Row(
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
                    state.activeCategory == "all" ? "آخر الأخبار" : "أخبار ${state.activeCategory}",
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...rest.map((a) => SmallNewsCard(
                article: a,
                isFavorite: _favorites.contains(a.id),
                onFavorite: () => _toggleFavorite(a.id),
              )).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(List<Article> results, bool isDark, String query) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "نتائج البحث عن: \"$query\"",
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (results.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 64, color: Color(0xFF9CA3AF)),
                    SizedBox(height: 16),
                    Text("لا توجد نتائج بحث مطابقة", style: TextStyle(color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
            )
          else
            ...results.map((a) => SmallNewsCard(
              article: a,
              isFavorite: _favorites.contains(a.id),
              onFavorite: () => _toggleFavorite(a.id),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: "ابحث في الأخبار...",
                  hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: _searchController.text.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: Color(0xFF9CA3AF)),
                        onPressed: () {
                          _searchController.clear();
                          context.read<NewsCubit>().searchNews("");
                        },
                      )
                    : null,
                ),
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827), fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
