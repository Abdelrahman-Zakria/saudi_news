import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/job_repository_impl.dart';
import 'jobs_state.dart';
import '../../domain/entities/job.dart';

class JobsCubit extends Cubit<JobsState> {
  final JobRepositoryImpl _repository = JobRepositoryImpl();

  JobsCubit() : super(JobsInitial());

  Future<void> init() async {
    await fetchJobs(limit: 10);
  }

  Future<void> fetchJobs({required int limit, bool isRefresh = false}) async {
    if (state is JobsLoading && !isRefresh) return;

    if (state is JobsInitial || isRefresh) {
      emit(JobsLoading());
    }

    try {
      final jobs = await _repository.getJobs(limit: limit);
      _updateJobs(jobs, limit);
    } catch (error) {
      emit(JobsError(error.toString()));
    }
  }

  void _updateJobs(List<Job> jobs, int limit) {
    String currentSearch = "";
    
    if (state is JobsLoaded) {
      currentSearch = (state as JobsLoaded).searchQuery;
    }

    final filtered = _applyFilters(jobs, currentSearch);

    emit(JobsLoaded(
      allJobs: jobs,
      filteredJobs: filtered,
      searchQuery: currentSearch,
      currentLimit: limit,
      hasMore: jobs.length >= limit,
    ));
  }

  List<Job> _applyFilters(List<Job> jobs, String search) {
    var filtered = jobs;
    if (search.isNotEmpty) {
      final lowercaseSearch = search.toLowerCase();
      filtered = filtered.where((j) => 
        j.title.toLowerCase().contains(lowercaseSearch) || 
        j.author.toLowerCase().contains(lowercaseSearch) ||
        j.description.toLowerCase().contains(lowercaseSearch)
      ).toList();
    }
    return filtered;
  }

  Future<void> loadMore() async {
    if (state is JobsLoaded) {
      final s = state as JobsLoaded;
      if (s.hasMore) {
        await fetchJobs(limit: s.currentLimit + 10);
      }
    }
  }

  Future<void> searchJobs(String query) async {
    if (state is JobsLoaded) {
      final s = state as JobsLoaded;
      emit(s.copyWith(searchQuery: query));
      await fetchJobs(limit: 10);
    }
  }
}
