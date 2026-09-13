import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/news_repository_impl.dart';
import 'news_state.dart';
import '../../domain/entities/article.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepositoryImpl _repository = NewsRepositoryImpl();
  final String baseCollection;
  String _activeCollection;

  NewsCubit({this.baseCollection = 'news'}) 
      : _activeCollection = baseCollection,
        super(NewsInitial());

  Future<void> init() async {
    await fetchArticles(limit: 50); // Fetch more to ensure we have enough for filtering
  }

  Future<void> fetchArticles({required int limit, bool isRefresh = false}) async {
    if (state is NewsLoading && !isRefresh) return;
    
    if (state is NewsInitial || isRefresh) {
      emit(NewsLoading());
    }

    try {
      final articles = await _repository.getNews(limit: limit, collection: _activeCollection);
      _updateArticles(articles, limit);
    } catch (error) {
      emit(NewsError(error.toString()));
    }
  }

  void _updateArticles(List<Article> articles, int limit) {
    String currentCategory = "all";
    String currentSearch = "";
    
    if (state is NewsLoaded) {
      currentCategory = (state as NewsLoaded).activeCategory;
      currentSearch = (state as NewsLoaded).searchQuery;
    }

    final now = DateTime.now();
    
    // Breaking news for ticker: Any item marked "عاجل" in last 24h
    final breaking = articles.where((a) {
      final diff = now.difference(a.createdAt.toLocal()).inHours;
      return (a.excerpt.contains('عاجل') || a.category.contains('عاجل')) && diff < 24;
    }).toList();

    final filtered = _applyFilters(articles, currentCategory, currentSearch);

    emit(NewsLoaded(
      allArticles: articles,
      filteredArticles: filtered,
      breakingNews: breaking,
      activeCategory: currentCategory,
      searchQuery: currentSearch,
      currentLimit: limit,
      hasMore: articles.length >= limit,
    ));
  }

  List<Article> _applyFilters(List<Article> articles, String category, String search) {
    var filtered = List<Article>.from(articles);
    final now = DateTime.now();
    
    if (category != "all" && category != 'تكنولوجيا' && category != 'رياضة' && category != 'وظائف') {
      filtered = filtered.where((a) {
        final artCat = a.category.toLowerCase();
        final text = a.excerpt.toLowerCase();
        final title = a.title.toLowerCase();
        
        switch (category) {
          case 'عام':
            return artCat == 'general' || artCat.contains('عام');
          case 'عاجل':
            // Robust check for "Breaking" articles in the last 12 hours
            // Using 12 hours instead of 3 to account for potential server/local clock drift
            final diffInHours = now.difference(a.createdAt.toLocal()).inHours;
            final isUrgent = artCat.contains('عاجل') || text.contains('عاجل') || title.contains('عاجل');
            return isUrgent && diffInHours < 12;
          default:
            return artCat == category.toLowerCase() || artCat.contains(category);
        }
      }).toList();
    } else if (category == 'عاجل') {
      // Fallback for cases where collection logic might skip the switch
      filtered = filtered.where((a) {
        final diffInHours = now.difference(a.createdAt.toLocal()).inHours;
        final isUrgent = a.category.contains('عاجل') || a.excerpt.contains('عاجل') || a.title.contains('عاجل');
        return isUrgent && diffInHours < 12;
      }).toList();
    }

    if (search.isNotEmpty) {
      final query = search.toLowerCase();
      filtered = filtered.where((a) {
        return a.title.toLowerCase().contains(query) ||
               a.excerpt.toLowerCase().contains(query);
      }).toList();
    }
    return filtered;
  }

  Future<void> loadMore() async {
    if (state is NewsLoaded) {
      final s = state as NewsLoaded;
      if (s.hasMore) {
        await fetchArticles(limit: s.currentLimit + 20);
      }
    }
  }

  Future<void> changeCategory(String categoryId) async {
    if (state is NewsLoaded) {
      final s = state as NewsLoaded;
      final String nextCategory = (s.activeCategory == categoryId) ? "all" : categoryId;
      
      if (baseCollection == 'news') {
        if (nextCategory == 'تكنولوجيا') {
          _activeCollection = 'technology';
        } else if (nextCategory == 'رياضة') {
          _activeCollection = 'spl';
        } else if (nextCategory == 'وظائف') {
          _activeCollection = 'jobs';
        } else {
          _activeCollection = 'news';
        }
      }

      emit(s.copyWith(activeCategory: nextCategory));
      await fetchArticles(limit: 50); 
    }
  }

  Future<void> searchNews(String query) async {
    if (state is NewsLoaded) {
      final s = state as NewsLoaded;
      emit(s.copyWith(searchQuery: query));
      await fetchArticles(limit: 30);
    }
  }
}
