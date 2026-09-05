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
    emit(JobsLoading());
    _subscription?.cancel();
    _subscription = _repository.getJobsStream().listen(
      (jobs) {
        _updateJobs(jobs);
      },
      onError: (error) {
        emit(JobsError(error.toString()));
      },
    );
  }

  void _updateJobs(List<Job> jobs) {
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

  void searchJobs(String query) {
    if (state is JobsLoaded) {
      final s = state as JobsLoaded;
      final filtered = _applyFilters(s.allJobs, query.toLowerCase(), s.activeCity);
      emit(s.copyWith(searchQuery: query, filteredJobs: filtered));
    }
  }

  void changeCity(String city) {
    if (state is JobsLoaded) {
      final s = state as JobsLoaded;
      
      // TOGGLE: If same city, go back to "الكل" (All)
      final String nextCity = (s.activeCity == city) ? "الكل" : city;
      
      final filtered = _applyFilters(s.allJobs, s.searchQuery, nextCity);
      emit(s.copyWith(activeCity: nextCity, filteredJobs: filtered));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
