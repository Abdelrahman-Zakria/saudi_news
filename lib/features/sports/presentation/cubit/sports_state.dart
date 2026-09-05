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

  SportsLoaded({
    required this.matches,
    required this.standings,
    required this.news,
    this.activeTab = 0,
  });

  SportsLoaded copyWith({
    List<Match>? matches,
    List<LeagueRow>? standings,
    List<Article>? news,
    int? activeTab,
  }) {
    return SportsLoaded(
      matches: matches ?? this.matches,
      standings: standings ?? this.standings,
      news: news ?? this.news,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

class SportsError extends SportsState {
  final String message;
  SportsError(this.message);
}
