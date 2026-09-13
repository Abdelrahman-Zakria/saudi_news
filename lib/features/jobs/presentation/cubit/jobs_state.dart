import '../../domain/entities/job.dart';

abstract class JobsState {}

class JobsInitial extends JobsState {}

class JobsLoading extends JobsState {}

class JobsLoaded extends JobsState {
  final List<Job> allJobs;
  final List<Job> filteredJobs;
  final String searchQuery;
  final int currentLimit;
  final bool hasMore;

  JobsLoaded({
    required this.allJobs,
    required this.filteredJobs,
    this.searchQuery = "",
    this.currentLimit = 10,
    this.hasMore = true,
  });

  JobsLoaded copyWith({
    List<Job>? allJobs,
    List<Job>? filteredJobs,
    String? searchQuery,
    int? currentLimit,
    bool? hasMore,
  }) {
    return JobsLoaded(
      allJobs: allJobs ?? this.allJobs,
      filteredJobs: filteredJobs ?? this.filteredJobs,
      searchQuery: searchQuery ?? this.searchQuery,
      currentLimit: currentLimit ?? this.currentLimit,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class JobsError extends JobsState {
  final String message;
  JobsError(this.message);
}
