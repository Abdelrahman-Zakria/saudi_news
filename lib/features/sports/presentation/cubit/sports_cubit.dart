import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/sports_repository_impl.dart';
import 'sports_state.dart';

class SportsCubit extends Cubit<SportsState> {
  final SportsRepositoryImpl _repository = SportsRepositoryImpl();
  StreamSubscription? _subscription;

  SportsCubit() : super(SportsInitial());

  void init() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    emit(SportsLoading());
    
    // Start news subscription
    _subscription?.cancel();
    _subscription = _repository.getSportsUpdatesStream(limit: 10).listen(
      (news) {
        _updateNews(news);
      },
      onError: (error) {
        emit(SportsError(error.toString()));
      },
    );

    // Fetch matches and standings in parallel
    try {
      final results = await Future.wait([
        _repository.getMatches(),
        _repository.getStandings(),
      ]);

      final matches = results[0] as List;
      final standings = results[1] as List;

      if (state is SportsLoaded) {
        emit((state as SportsLoaded).copyWith(
          matches: List.from(matches),
          standings: List.from(standings),
        ));
      } else {
        emit(SportsLoaded(
          matches: List.from(matches),
          standings: List.from(standings),
          news: [],
        ));
      }
    } catch (e) {
      // Keep existing data or show error if initial load fails
      if (state is! SportsLoaded) {
        emit(SportsError(e.toString()));
      }
    }
  }

  void _updateNews(List<dynamic> news) {
    if (state is SportsLoaded) {
      final s = state as SportsLoaded;
      emit(s.copyWith(
        news: List.from(news),
        hasMore: news.length >= s.currentLimit,
      ));
    } else {
      emit(SportsLoaded(
        matches: [],
        standings: [],
        news: List.from(news),
      ));
    }
  }

  void loadMore() {
    if (state is SportsLoaded) {
      final s = state as SportsLoaded;
      if (s.hasMore && s.activeTab == 2) {
        final newLimit = s.currentLimit + 10;
        _subscription?.cancel();
        _subscription = _repository.getSportsUpdatesStream(limit: newLimit).listen(
          (news) {
            emit(s.copyWith(
              news: List.from(news),
              currentLimit: newLimit,
              hasMore: news.length >= newLimit,
            ));
          },
        );
      }
    }
  }

  void changeTab(int index) {
    if (state is SportsLoaded) {
      emit((state as SportsLoaded).copyWith(activeTab: index));
      // Refresh data if switching to matches or standings
      if (index == 0 || index == 1) {
        _refreshSportsData();
      }
    }
  }

  Future<void> _refreshSportsData() async {
    try {
      final results = await Future.wait([
        _repository.getMatches(),
        _repository.getStandings(),
      ]);
      if (state is SportsLoaded) {
        emit((state as SportsLoaded).copyWith(
          matches: List.from(results[0]),
          standings: List.from(results[1]),
        ));
      }
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
