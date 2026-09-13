import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/sports_repository_impl.dart';
import 'sports_state.dart';

class SportsCubit extends Cubit<SportsState> {
  final SportsRepositoryImpl _repository = SportsRepositoryImpl();

  SportsCubit() : super(SportsInitial());

  Future<void> init() async {
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    emit(SportsLoading());
    
    try {
      final results = await Future.wait([
        _repository.getSportsUpdates(limit: 10),
        _repository.getMatches(),
        _repository.getStandings(),
      ]);

      final news = results[0] as List<dynamic>;
      final matches = results[1] as List;
      final standings = results[2] as List;

      emit(SportsLoaded(
        matches: List.from(matches),
        standings: List.from(standings),
        news: List.from(news),
        currentLimit: 10,
        hasMore: news.length >= 10,
      ));
    } catch (e) {
      if (state is! SportsLoaded) {
        emit(SportsError(e.toString()));
      }
    }
  }

  Future<void> loadMore() async {
    if (state is SportsLoaded) {
      final s = state as SportsLoaded;
      if (s.hasMore && s.activeTab == 0) { // News tab
        final newLimit = s.currentLimit + 10;
        try {
          final news = await _repository.getSportsUpdates(limit: newLimit);
          emit(s.copyWith(
            news: List.from(news),
            currentLimit: newLimit,
            hasMore: news.length >= newLimit,
          ));
        } catch (_) {}
      }
    }
  }

  void changeTab(int index) {
    if (state is SportsLoaded) {
      emit((state as SportsLoaded).copyWith(activeTab: index));
      if (index == 1 || index == 2) {
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
}
