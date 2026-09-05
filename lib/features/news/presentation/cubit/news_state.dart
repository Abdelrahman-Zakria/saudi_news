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

  NewsLoaded({
    required this.allArticles,
    required this.filteredArticles,
    required this.breakingNews,
    this.activeCategory = "all",
    this.searchQuery = "",
  });

  NewsLoaded copyWith({
    List<Article>? allArticles,
    List<Article>? filteredArticles,
    List<Article>? breakingNews,
    String? activeCategory,
    String? searchQuery,
  }) {
    return NewsLoaded(
      allArticles: allArticles ?? this.allArticles,
      filteredArticles: filteredArticles ?? this.filteredArticles,
      breakingNews: breakingNews ?? this.breakingNews,
      activeCategory: activeCategory ?? this.activeCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class NewsError extends NewsState {
  final String message;
  NewsError(this.message);
}
