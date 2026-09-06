import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/sports_cubit.dart';
import '../cubit/sports_state.dart';
import 'package:saudi_news/features/news/presentation/widgets/small_news_card.dart';

class SportsScreen extends StatefulWidget {
  const SportsScreen({super.key});

  @override
  State<SportsScreen> createState() => _SportsScreenState();
}

class _SportsScreenState extends State<SportsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<SportsCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<SportsCubit, SportsState>(
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF9FAFB),
            body: SafeArea(
              child: Column(
                children: [
                  _buildToggle(context, state),
                  Expanded(
                    child: _buildTabContent(state),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggle(BuildContext context, SportsState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int activeTab = state is SportsLoaded ? state.activeTab : 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            _buildToggleItem(context, 0, "📅 المباريات", activeTab == 0),
            _buildToggleItem(context, 1, "📊 الترتيب", activeTab == 1),
            _buildToggleItem(context, 2, "📰 الأخبار", activeTab == 2),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(BuildContext context, int index, String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<SportsCubit>().changeTab(index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF006C35) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563)),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(SportsState state) {
    if (state is SportsLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
    }

    if (state is SportsError) {
      return Center(child: Text(state.message));
    }

    if (state is SportsLoaded) {
      switch (state.activeTab) {
        case 0:
          return _buildMatchesTab(state);
        case 1:
          return _buildStandingsTab(state);
        case 2:
          return _buildNewsTab(state);
        default:
          return const SizedBox.shrink();
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildMatchesTab(SportsLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.matches.length,
      itemBuilder: (context, index) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final match = state.matches[index];
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      match.league,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: match.status == "انتهت" 
                        ? (isDark ? const Color(0xFF374151) : const Color(0xFFF0FDF4))
                        : (isDark ? const Color(0xFF1E3A8A).withValues(alpha:0.3) : const Color(0xFFEFF6FF)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      match.status == "انتهت" ? "✅ اليوم" : "🕐 ${match.time} • غداً",
                      style: TextStyle(
                        color: match.status == "انتهت" 
                          ? (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF15803D))
                          : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8)),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(match.homeLogo, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(match.homeTeam, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "${match.homeScore} - ${match.awayScore}",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(match.awayLogo, style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(match.awayTeam, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStandingsTab(SportsLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B22) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)),
              ),
              child: DataTable(
                columnSpacing: 20,
                horizontalMargin: 12,
                headingRowHeight: 45,
                columns: const [
                  DataColumn(label: Text("#", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("الفريق", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("ل", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("ت", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("ف", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text("ن", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                ],
                rows: state.standings.map((row) {
                  return DataRow(cells: [
                    DataCell(Text(row.pos.toString(), style: const TextStyle(fontSize: 12))),
                    DataCell(Row(
                      children: [
                        Text(row.logo, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(row.team, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    )),
                    DataCell(Text(row.played.toString(), style: const TextStyle(fontSize: 12))),
                    DataCell(Text(row.draws.toString(), style: const TextStyle(fontSize: 12))),
                    DataCell(Text(row.wins.toString(), style: const TextStyle(fontSize: 12))),
                    DataCell(Text(row.pts.toString(), style: const TextStyle(color: Color(0xFF006C35), fontWeight: FontWeight.bold, fontSize: 12))),
                  ]);
                }).toList(),
              ),
            );
          }
        ),
    );
  }

  Widget _buildNewsTab(SportsLoaded state) {
    if (state.news.isEmpty) {
      return const Center(child: Text("لا توجد أخبار رياضية حالياً", style: TextStyle(color: Color(0xFF9CA3AF))));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.news.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.news.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator(color: Color(0xFF006C35))),
          );
        }
        return SmallNewsCard(
          article: state.news[index],
          isFavorite: false,
          onFavorite: () {},
        );
      },
    );
  }
}
