import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/news_repository_impl.dart';
import 'news_state.dart';
import '../../domain/entities/article.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepositoryImpl _repository = NewsRepositoryImpl();
  StreamSubscription? _subscription;

  NewsCubit() : super(NewsInitial());

  void init() {
    emit(NewsLoading());
    _subscription?.cancel();
    _subscription = _repository.getNewsStream().listen(
      (articles) {
        _updateArticles(articles);
      },
      onError: (error) {
        emit(NewsError(error.toString()));
      },
    );
  }

  void _updateArticles(List<Article> articles) {
    String currentCategory = "all";
    String currentSearch = "";
    
    if (state is NewsLoaded) {
      currentCategory = (state as NewsLoaded).activeCategory;
      currentSearch = (state as NewsLoaded).searchQuery;
    }

    final now = DateTime.now();
    final breaking = articles.where((a) {
      final difference = now.difference(a.createdAt).inHours;
      return a.excerpt.contains('عاجل') && difference < 24;
    }).toList();

    final filtered = _applyFilters(articles, currentCategory, currentSearch);

    emit(NewsLoaded(
      allArticles: articles,
      filteredArticles: filtered,
      breakingNews: breaking,
      activeCategory: currentCategory,
      searchQuery: currentSearch,
    ));
  }

  List<Article> _applyFilters(List<Article> articles, String category, String search) {
    var filtered = articles;
    
    if (category != "all") {
      filtered = filtered.where((a) {
        final artCat = a.category.toLowerCase();
        // Exact match with English ID OR Exact match with Arabic Label OR contains Arabic Label
        // This covers "tech" vs "تكنولوجيا" and "ksa" vs "سياسة" etc.
        switch (category) {
          case 'سياسة':
            return artCat == 'politics' || artCat.contains('سياسة') || artCat == 'ksa';
          case 'اقتصاد':
            return artCat == 'economy' || artCat.contains('اقتصاد');
          case 'مجتمع':
            return artCat == 'society' || artCat.contains('مجتمع');
          case 'تكنولوجيا':
            return artCat == 'tech' || artCat.contains('تكنولوجيا') || artCat.contains('تقنية');
          case 'رياضة':
            return artCat == 'sports' || artCat.contains('رياضة');
          case 'عاجل':
            return artCat == 'breaking' || artCat.contains('عاجل');
          case 'عام':
            return artCat == 'general' || artCat.contains('عام');
          default:
            return artCat == category.toLowerCase() || artCat.contains(category);
        }
      }).toList();
    }

    if (search.isNotEmpty) {
      filtered = filtered.where((a) {
        return a.title.toLowerCase().contains(search) ||
               a.excerpt.toLowerCase().contains(search);
      }).toList();
    }
    return filtered;
  }

  void changeCategory(String categoryId) {
    if (state is NewsLoaded) {
      final s = state as NewsLoaded;
      
      // TOGGLE: If selecting the same active category, go back to "all"
      final String nextCategory = (s.activeCategory == categoryId) ? "all" : categoryId;
      
      final filtered = _applyFilters(s.allArticles, nextCategory, s.searchQuery);
      emit(s.copyWith(activeCategory: nextCategory, filteredArticles: filtered));
    }
  }

  void searchNews(String query) {
    if (state is NewsLoaded) {
      final s = state as NewsLoaded;
      final filtered = _applyFilters(s.allArticles, s.activeCategory, query.toLowerCase());
      emit(s.copyWith(searchQuery: query, filteredArticles: filtered));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
