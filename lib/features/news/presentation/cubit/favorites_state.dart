import 'package:equatable/equatable.dart';
import '../../domain/entities/article.dart';

abstract class FavoritesState extends Equatable {
  final List<String> favoriteIds;
  
  const FavoritesState(this.favoriteIds);

  @override
  List<Object?> get props => [favoriteIds];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial() : super(const []);
}

class FavoritesLoaded extends FavoritesState {
  final List<Article> favoriteArticles;
  
  const FavoritesLoaded({
    required List<String> favoriteIds, 
    required this.favoriteArticles,
  }) : super(favoriteIds);

  @override
  List<Object?> get props => [favoriteIds, favoriteArticles];
}
