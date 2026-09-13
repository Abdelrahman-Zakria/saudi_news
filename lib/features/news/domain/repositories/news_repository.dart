import '../entities/article.dart';

abstract class NewsRepository {
  Future<List<Article>> getNews({int limit = 10, String collection = 'news'});
  Future<Article?> getArticleById(String id, {String collection = 'news'});
}
