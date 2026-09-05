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

  final List<String> _cities = ["الكل", "الرياض", "جدة", "الدمام", "مكة", "المدينة"];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      context.read<JobsCubit>().searchJobs(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<JobsCubit, JobsState>(
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              _buildSearchBar(context, isDark),
              _buildCityFilter(context, isDark, state),
              Expanded(
                child: _buildJobsList(state),
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

  Widget _buildCityFilter(BuildContext context, bool isDark, JobsState state) {
    final String activeCity = state is JobsLoaded ? state.activeCity : "الكل";

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          final city = _cities[index];
          final isSelected = activeCity == city;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(city),
              selected: isSelected,
              onSelected: (selected) {
                context.read<JobsCubit>().changeCity(city);
              },
              selectedColor: const Color(0xFF006C35),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 12,
              ),
              backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.grey[200],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJobsList(JobsState state) {
    if (state is JobsLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
    }

    if (state is JobsError) {
      return Center(child: Text(state.message));
    }

    if (state is JobsLoaded) {
      if (state.filteredJobs.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("💼", style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              Text("لا توجد وظائف مطابقة للبحث حالياً", style: TextStyle(color: Color(0xFF9CA3AF))),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: state.filteredJobs.length,
        itemBuilder: (context, index) {
          return JobCard(job: state.filteredJobs[index]);
        },
      );
    }

    return const SizedBox.shrink();
  }
}
