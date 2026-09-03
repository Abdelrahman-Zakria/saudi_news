import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/news_repository.dart';
import '../models/article_model.dart';

class NewsRepositoryImpl implements NewsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<Article>> getNewsStream() {
    return _firestore
        .collection('news')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc))
          .toList();
    });
  }
}
