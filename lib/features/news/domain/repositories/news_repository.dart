import '../entities/article.dart';

abstract class NewsRepository {
  Stream<List<Article>> getNewsStream({int limit = 10, String collection = 'news'});
  Future<Article?> getArticleById(String id, {String collection = 'news'});
}
