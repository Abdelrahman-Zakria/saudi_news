import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/jobs_cubit.dart';
import '../cubit/jobs_state.dart';
import '../widgets/job_card.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<JobsCubit>().searchJobs(_searchController.text);
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<JobsCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<JobsCubit, JobsState>(
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              _buildSearchBar(context, isDark),
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFF006C35),
                  onRefresh: () => context.read<JobsCubit>().fetchJobs(limit: 10, isRefresh: true),
                  child: _buildJobsList(state),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: "ابحث عن وظيفة، شركة...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsList(JobsState state) {
    if (state is JobsLoading && state is! JobsLoaded) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
    }

    if (state is JobsError) {
      return Center(child: Text(state.message));
    }

    if (state is JobsLoaded) {
      if (state.filteredJobs.isEmpty) {
        return ListView( // Wrap in ListView to allow pull-to-refresh on empty state
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("💼", style: TextStyle(fontSize: 48)),
                  SizedBox(height: 16),
                  Text("لا توجد وظائف مطابقة للبحث حالياً", style: TextStyle(color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
          ],
        );
      }

      return ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: state.filteredJobs.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.filteredJobs.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF006C35))),
            );
          }
          return JobCard(job: state.filteredJobs[index]);
        },
      );
    }

    return const SizedBox.shrink();
  }
}
