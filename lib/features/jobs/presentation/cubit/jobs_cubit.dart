import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/job_repository_impl.dart';
import 'jobs_state.dart';
import '../../domain/entities/job.dart';

class JobsCubit extends Cubit<JobsState> {
  final JobRepositoryImpl _repository = JobRepositoryImpl();
  StreamSubscription? _subscription;

  JobsCubit() : super(JobsInitial());

  void init() {
    _startSubscription(limit: 10);
  }

  void _startSubscription({required int limit}) {
    if (state is JobsInitial) {
      emit(JobsLoading());
    }

    _subscription?.cancel();
    _subscription = _repository.getJobsStream(limit: limit).listen(
      (jobs) {
        _updateJobs(jobs, limit);
      },
      onError: (error) {
        emit(JobsError(error.toString()));
      },
    );
  }

  void _updateJobs(List<Job> jobs, int limit) {
    String currentSearch = "";
    String currentCity = "الكل";
    
    if (state is JobsLoaded) {
      currentSearch = (state as JobsLoaded).searchQuery;
      currentCity = (state as JobsLoaded).activeCity;
    }

    final filtered = _applyFilters(jobs, currentSearch, currentCity);

    emit(JobsLoaded(
      allJobs: jobs,
      filteredJobs: filtered,
      searchQuery: currentSearch,
      activeCity: currentCity,
      currentLimit: limit,
      hasMore: jobs.length >= limit,
    ));
  }

  List<Job> _applyFilters(List<Job> jobs, String search, String city) {
    var filtered = jobs;
    if (city != "الكل") {
      filtered = filtered.where((j) => j.city == city).toList();
    }
    if (search.isNotEmpty) {
      filtered = filtered.where((j) => 
        j.title.toLowerCase().contains(search) || 
        j.company.toLowerCase().contains(search)
      ).toList();
    }
    return filtered;
  }

  void loadMore() {
    if (state is JobsLoaded) {
      final s = state as JobsLoaded;
      if (s.hasMore) {
        _startSubscription(limit: s.currentLimit + 10);
      }
    }
  }

  void searchJobs(String query) {
    if (state is JobsLoaded) {
      final s = state as JobsLoaded;
      _startSubscription(limit: 10);
      emit(s.copyWith(searchQuery: query));
    }
  }

  void changeCity(String city) {
    if (state is JobsLoaded) {
      final s = state as JobsLoaded;
      final String nextCity = (s.activeCity == city) ? "الكل" : city;
      _startSubscription(limit: 10);
      emit(s.copyWith(activeCity: nextCity));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
