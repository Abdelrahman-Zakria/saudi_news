import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../domain/entities/article.dart';
import '../../data/repositories/news_repository_impl.dart';
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
  final _repository = NewsRepositoryImpl();
  String _activeCategory = "all";
  final Set<String> _favorites = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  Timer? _debounce;
  bool _isSearching = false;

  final List<CategoryItem> _sections = [
    CategoryItem(id: "all", label: "الكل"),
    CategoryItem(id: "ksa", label: "🇸🇦 السعودية"),
    CategoryItem(id: "tech", label: "💻 تقنية"),
    CategoryItem(id: "sports", label: "⚽ رياضة"),
    CategoryItem(id: "economy", label: "💼 اقتصاد"),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
          _isSearching = _searchQuery.isNotEmpty;
        });
      }
    });
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

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Article>>(
          stream: _repository.getNewsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
            }

            final allArticles = snapshot.data!;
            if (allArticles.isEmpty) {
              return const Center(child: Text('لا توجد أخبار'));
            }

            // Filter for Breaking Ticker: Has "عاجل" and posted recently (last 24 hours)
            final now = DateTime.now();
            final breakingNews = allArticles.where((a) {
              final difference = now.difference(a.createdAt).inHours;
              return a.excerpt.contains('عاجل') && difference < 24;
            }).toList();

            // Apply category filter
            var filtered = allArticles.where((a) {
              return _activeCategory == "all" || a.category == _activeCategory;
            }).toList();

            // Apply search filter
            if (_searchQuery.isNotEmpty) {
              filtered = filtered.where((a) {
                return a.title.toLowerCase().contains(_searchQuery) ||
                    a.excerpt.toLowerCase().contains(_searchQuery);
              }).toList();
            }

            return Directionality(
              textDirection: TextDirection.rtl,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildSearchBar(context),
                  
                  if (!_isSearching) ...[
                    const BreakingTicker(articles: []), // Logic handled inside widget usually, passing breakingNews if needed
                    // Re-adding breakingNews if your BreakingTicker expects it
                  ],

                  if (_isSearching)
                    _buildSearchResults(filtered, isDark, theme)
                  else
                    _buildHomeContent(allArticles, filtered, breakingNews, isDark, theme),
                  
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHomeContent(List<Article> allArticles, List<Article> filtered, List<Article> breakingNews, bool isDark, ThemeData theme) {
    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text("لا توجد أخبار في هذا القسم")),
      );
    }

    final featured = filtered.first;
    final mostRead = filtered.take(3).toList();
    final rest = filtered; // Showing all in "Latest" as requested before

    return Column(
      children: [
        BreakingTicker(articles: breakingNews),
        
        // Featured Article
        Padding(
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
        ),

        CategoryPills(
          categories: _sections,
          activeCategoryId: _activeCategory,
          onCategorySelected: (id) {
            setState(() {
              _activeCategory = id;
            });
          },
        ),

        // Most Read Section
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

        // Latest Section
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
                    "آخر الأخبار",
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

  Widget _buildSearchResults(List<Article> results, bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "نتائج البحث عن: \"$_searchQuery\"",
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
                          setState(() {
                            _searchQuery = "";
                            _isSearching = false;
                          });
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
