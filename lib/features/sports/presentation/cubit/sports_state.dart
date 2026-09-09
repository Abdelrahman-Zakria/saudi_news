import '../../domain/entities/match.dart';
import '../../domain/entities/league_row.dart';
import '../../../news/domain/entities/article.dart';

abstract class SportsState {}

class SportsInitial extends SportsState {}

class SportsLoading extends SportsState {}

class SportsLoaded extends SportsState {
  final List<Match> matches;
  final List<LeagueRow> standings;
  final List<Article> news;
  final int activeTab;
  final int currentLimit;
  final bool hasMore;

  SportsLoaded({
    required this.matches,
    required this.standings,
    required this.news,
    this.activeTab = 0,
    this.currentLimit = 10,
    this.hasMore = true,
  });

  SportsLoaded copyWith({
    List<Match>? matches,
    List<LeagueRow>? standings,
    List<Article>? news,
    int? activeTab,
    int? currentLimit,
    bool? hasMore,
  }) {
    return SportsLoaded(
      matches: matches ?? this.matches,
      standings: standings ?? this.standings,
      news: news ?? this.news,
      activeTab: activeTab ?? this.activeTab,
      currentLimit: currentLimit ?? this.currentLimit,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class SportsError extends SportsState {
  final String message;
  SportsError(this.message);
}
