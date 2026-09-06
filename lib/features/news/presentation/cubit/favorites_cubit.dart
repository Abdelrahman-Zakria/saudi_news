import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/settings_service.dart';
import 'favorites_state.dart';
import '../../domain/entities/article.dart';
import '../../data/models/article_model.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final SettingsService _settingsService = SettingsService();
  List<Article> _favoriteArticles = [];

  FavoritesCubit() : super(const FavoritesInitial()) {
    _loadFavorites();
  }

  void _loadFavorites() {
    final ids = _settingsService.favoriteIds;
    final cachedData = _settingsService.getCachedFavoriteArticles();
    
    _favoriteArticles = cachedData.map((json) {
      return ArticleModel.fromJson(jsonDecode(json));
    }).toList();

    emit(FavoritesLoaded(
      favoriteIds: List<String>.from(ids), 
      favoriteArticles: List<Article>.from(_favoriteArticles),
    ));
  }

  bool isFavorite(String id) {
    return state.favoriteIds.contains(id);
  }

  Future<void> toggleFavorite(Article article) async {
    final List<String> currentIds = List<String>.from(state.favoriteIds);
    final List<String> currentCached = List<String>.from(_settingsService.getCachedFavoriteArticles());
    
    if (currentIds.contains(article.id)) {
      currentIds.remove(article.id);
      _favoriteArticles.removeWhere((a) => a.id == article.id);
      
      currentCached.removeWhere((json) {
        final data = jsonDecode(json);
        final id = data['tweetId'] ?? data['id'];
        return id == article.id;
      });
    } else {
      currentIds.add(article.id);
      _favoriteArticles.insert(0, article);
      
      final articleMap = {
        'tweetId': article.id,
        'category': article.category,
        'text': article.excerpt,
        'author': article.source,
        'timestamp': article.createdAt.toIso8601String(),
        'createdAt': article.twitterDate,
        'likeCount': article.likeCount,
        'retweetCount': article.retweetCount,
        'replyCount': article.replyCount,
        'media': article.mediaUrls.map((url) => {'media_url_https': url, 'type': 'photo'}).toList(),
        'videoUrl': article.videoUrl,
        'engagement': article.engagement,
      };
      currentCached.add(jsonEncode(articleMap));
    }
    
    await _settingsService.setFavoriteIds(currentIds);
    await _settingsService.setCachedFavoriteArticles(currentCached);
    
    emit(FavoritesLoaded(
      favoriteIds: List<String>.from(currentIds), 
      favoriteArticles: List<Article>.from(_favoriteArticles),
    ));
  }
}
