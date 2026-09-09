import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/news_repository_impl.dart';
import 'news_state.dart';
import '../../domain/entities/article.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepositoryImpl _repository = NewsRepositoryImpl();
  final String collection;
  StreamSubscription? _subscription;

  NewsCubit({this.collection = 'news'}) : super(NewsInitial());

  void init() {
    _startSubscription(limit: 10);
  }

  void _startSubscription({required int limit}) {
    if (state is NewsLoading) return;
    
    if (state is NewsInitial) {
      emit(NewsLoading());
    }

    _subscription?.cancel();
    _subscription = _repository.getNewsStream(limit: limit, collection: collection).listen(
      (articles) {
        _updateArticles(articles, limit);
      },
      onError: (error) {
        emit(NewsError(error.toString()));
      },
    );
  }

  void _updateArticles(List<Article> articles, int limit) {
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
      currentLimit: limit,
      hasMore: articles.length >= limit,
    ));
  }

  List<Article> _applyFilters(List<Article> articles, String category, String search) {
    var filtered = articles;
    
    if (category != "all") {
      filtered = filtered.where((a) {
        final artCat = a.category.toLowerCase();
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

  void loadMore() {
    if (state is NewsLoaded) {
      final s = state as NewsLoaded;
      if (s.hasMore) {
        _startSubscription(limit: s.currentLimit + 10);
      }
    }
  }

  void changeCategory(String categoryId) {
    if (state is NewsLoaded) {
      final s = state as NewsLoaded;
      final String nextCategory = (s.activeCategory == categoryId) ? "all" : categoryId;
      _startSubscription(limit: 10); 
      emit(s.copyWith(activeCategory: nextCategory));
    }
  }

  void searchNews(String query) {
    if (state is NewsLoaded) {
      final s = state as NewsLoaded;
      _startSubscription(limit: 10);
      emit(s.copyWith(searchQuery: query));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
