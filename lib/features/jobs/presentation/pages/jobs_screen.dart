import 'package:flutter/material.dart';
import '../../data/repositories/job_repository_impl.dart';
import '../../domain/entities/job.dart';
import '../widgets/job_card.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _repository = JobRepositoryImpl();
  String _activeCity = "الكل";
  String _searchQuery = "";

  final List<String> _cities = [
    "الكل",
    "الرياض",
    "جدة",
    "الدمام",
    "عن بُعد",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: StreamBuilder<List<Job>>(
            stream: _repository.getJobsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
              }

              final jobs = snapshot.data ?? [];
              final filteredJobs = jobs.where((job) {
                final matchesSearch = job.title.contains(_searchQuery) || 
                                    job.company.contains(_searchQuery);
                if (!matchesSearch) return false;
                
                if (_activeCity == "الكل") return true;
                if (_activeCity == "عن بُعد") return job.type == "عن بُعد";
                return job.city == _activeCity;
              }).toList();

              return Column(
                children: [
                  _buildHeader(context),
                  _buildCityFilters(context),
                  Expanded(
                    child: filteredJobs.isEmpty 
                      ? const Center(child: Text("لا توجد وظائف متاحة", style: TextStyle(color: Color(0xFF9CA3AF))))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: filteredJobs.length,
                          itemBuilder: (context, index) {
                            return JobCard(job: filteredJobs[index]);
                          },
                        ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? const Color(0xFF161B22) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الوظائف',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    textAlign: TextAlign.right,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "ابحث عن وظيفة، شركة...",
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827), fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityFilters(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          final city = _cities[index];
          final isActive = _activeCity == city;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _activeCity = city;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF006C35)
                    : (isDark ? const Color(0xFF1F2937) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFF006C35)
                      : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                city,
                style: TextStyle(
                  color: isActive ? Colors.white : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563)),
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
