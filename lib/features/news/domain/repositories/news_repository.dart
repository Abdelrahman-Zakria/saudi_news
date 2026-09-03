import '../entities/article.dart';

abstract class NewsRepository {
  Stream<List<Article>> getNewsStream();
}
