import '../../domain/entities/article.dart';

abstract class NewsState {}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<Article> allArticles;
  final List<Article> filteredArticles;
  final List<Article> breakingNews;
  final String activeCategory;
  final String searchQuery;
  final int currentLimit;
  final bool hasMore;

  NewsLoaded({
    required this.allArticles,
    required this.filteredArticles,
    required this.breakingNews,
    this.activeCategory = "all",
    this.searchQuery = "",
    this.currentLimit = 10,
    this.hasMore = true,
  });

  NewsLoaded copyWith({
    List<Article>? allArticles,
    List<Article>? filteredArticles,
    List<Article>? breakingNews,
    String? activeCategory,
    String? searchQuery,
    int? currentLimit,
    bool? hasMore,
  }) {
    return NewsLoaded(
      allArticles: allArticles ?? this.allArticles,
      filteredArticles: filteredArticles ?? this.filteredArticles,
      breakingNews: breakingNews ?? this.breakingNews,
      activeCategory: activeCategory ?? this.activeCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      currentLimit: currentLimit ?? this.currentLimit,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class NewsError extends NewsState {
  final String message;
  NewsError(this.message);
}
