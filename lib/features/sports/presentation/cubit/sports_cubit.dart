import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/sports_repository_impl.dart';
import 'sports_state.dart';
import '../../domain/entities/match.dart';
import '../../domain/entities/league_row.dart';

class SportsCubit extends Cubit<SportsState> {
  final SportsRepositoryImpl _repository = SportsRepositoryImpl();
  StreamSubscription? _subscription;

  SportsCubit() : super(SportsInitial());

  void init() {
    _startSubscription(limit: 10);
  }

  void _startSubscription({required int limit}) {
    if (state is SportsInitial) {
      emit(SportsLoading());
    }

    _subscription?.cancel();
    _subscription = _repository.getSportsUpdatesStream(limit: limit).listen(
      (news) {
        _updateData(news: news, limit: limit);
      },
      onError: (error) {
        emit(SportsError(error.toString()));
      },
    );

    // Initial dummy data for matches and standings
    _updateData(
      matches: [
        Match(
          id: "1",
          league: "دوري روشن السعودي",
          homeTeam: "الهلال",
          awayTeam: "النصر",
          homeScore: "3",
          awayScore: "0",
          homeLogo: "🔵",
          awayLogo: "🟡",
          status: "انتهت",
          time: "21:00",
          date: "2026-09-01",
        ),
        Match(
          id: "2",
          league: "دوري روشن السعودي",
          homeTeam: "الاتحاد",
          awayTeam: "الأهلي",
          homeScore: "0",
          awayScore: "0",
          homeLogo: "🟡",
          awayLogo: "🟢",
          status: "20:00",
          time: "20:00",
          date: "2026-09-02",
        ),
      ],
      standings: [
        LeagueRow(pos: 1, team: "الهلال", played: 20, wins: 18, draws: 2, losses: 0, pts: 56, logo: "🔵"),
        LeagueRow(pos: 2, team: "النصر", played: 20, wins: 15, draws: 2, losses: 3, pts: 47, logo: "🟡"),
        LeagueRow(pos: 3, team: "الاتحاد", played: 20, wins: 11, draws: 4, losses: 5, pts: 37, logo: "🟡"),
        LeagueRow(pos: 4, team: "الأهلي", played: 20, wins: 10, draws: 4, losses: 6, pts: 34, logo: "🟢"),
      ],
    );
  }

  void _updateData({List<Match>? matches, List<LeagueRow>? standings, List<dynamic>? news, int? limit}) {
    if (state is SportsLoaded) {
      final s = state as SportsLoaded;
      emit(s.copyWith(
        matches: matches,
        standings: standings,
        news: news != null ? List.from(news) : null,
        currentLimit: limit,
        hasMore: news != null ? news.length >= (limit ?? 10) : null,
      ));
    } else {
      emit(SportsLoaded(
        matches: matches ?? [],
        standings: standings ?? [],
        news: news != null ? List.from(news) : [],
        currentLimit: limit ?? 10,
        hasMore: news != null ? news.length >= (limit ?? 10) : true,
      ));
    }
  }

  void loadMore() {
    if (state is SportsLoaded) {
      final s = state as SportsLoaded;
      if (s.hasMore && s.activeTab == 2) { // Only news tab is paginated for now
        _startSubscription(limit: s.currentLimit + 10);
      }
    }
  }

  void changeTab(int index) {
    if (state is SportsLoaded) {
      emit((state as SportsLoaded).copyWith(activeTab: index));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
