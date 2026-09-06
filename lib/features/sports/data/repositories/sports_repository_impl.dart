import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saudi_news/features/news/domain/entities/article.dart';
import 'package:saudi_news/features/news/data/models/article_model.dart';

class SportsRepositoryImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Article>> getSportsUpdatesStream({int limit = 10}) {
    return _firestore
        .collection('spl')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ArticleModel.fromFirestore(doc)).toList();
    });
  }
}
