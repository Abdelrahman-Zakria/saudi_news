import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/sports_cubit.dart';
import '../cubit/sports_state.dart';
import 'package:saudi_news/features/news/presentation/widgets/small_news_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                    child: RefreshIndicator(
                      color: const Color(0xFF006C35),
                      onRefresh: () async {
                         context.read<SportsCubit>().init();
                      },
                      child: _buildTabContent(state),
                    ),
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
            _buildToggleItem(context, 0, "📰 الأخبار", activeTab == 0),
            _buildToggleItem(context, 1, "📅 المباريات", activeTab == 1),
            _buildToggleItem(context, 2, "📊 الترتيب", activeTab == 2),
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
          return _buildNewsTab(state);
        case 1:
          return _buildMatchesTab(state);
        case 2:
          return _buildStandingsTab(state);
        default:
          return const SizedBox.shrink();
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildMatchesTab(SportsLoaded state) {
    if (state.matches.isEmpty) {
      return const Center(child: Text("لا توجد مباريات حالياً", style: TextStyle(color: Color(0xFF9CA3AF))));
    }

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
                color: Colors.black.withOpacity(0.05),
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
                        : (isDark ? const Color(0xFF1E3A8A).withOpacity(0.3) : const Color(0xFFEFF6FF)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      match.status == "انتهت" ? "✅ انتهت" : "🕐 ${match.time}",
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
                        _buildTeamLogo(match.homeLogo, 40),
                        const SizedBox(height: 8),
                        Text(
                          match.homeTeam, 
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
                        ),
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
                        _buildTeamLogo(match.awayLogo, 40),
                        const SizedBox(height: 8),
                        Text(
                          match.awayTeam, 
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
                        ),
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
    if (state.standings.isEmpty) {
      return const Center(child: Text("لا توجد بيانات ترتيب حالياً", style: TextStyle(color: Color(0xFF9CA3AF))));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    const headerStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9CA3AF));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Header Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937).withOpacity(0.5) : const Color(0xFFF9FAFB),
                  border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6))),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 30, child: Text("#", style: headerStyle, textAlign: TextAlign.center)),
                    Expanded(child: Text("الفريق", style: headerStyle)),
                    SizedBox(width: 35, child: Text("ل", style: headerStyle, textAlign: TextAlign.center)),
                    SizedBox(width: 35, child: Text("ف", style: headerStyle, textAlign: TextAlign.center)),
                    SizedBox(width: 35, child: Text("ت", style: headerStyle, textAlign: TextAlign.center)),
                    SizedBox(width: 35, child: Text("خ", style: headerStyle, textAlign: TextAlign.center)),
                    SizedBox(width: 40, child: Text("ن", style: headerStyle, textAlign: TextAlign.center)),
                  ],
                ),
              ),
              // Team Rows
              ...state.standings.map((row) {
                final isTop3 = row.pos <= 3;
                final isLast3 = row.pos >= state.standings.length - 2;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6))),
                  ),
                  child: Row(
                    children: [
                      // Position with Indicator
                      SizedBox(
                        width: 30,
                        child: Row(
                          children: [
                            if (isTop3)
                              Container(width: 3, height: 16, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(2))),
                            if (isLast3)
                              Container(width: 3, height: 16, decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(2))),
                            if (!isTop3 && !isLast3)
                              const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                row.pos.toString(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Team Info
                      Expanded(
                        child: Row(
                          children: [
                            _buildTeamLogo(row.logo, 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                row.team,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Stats
                      _buildStatCell(row.played.toString(), isDark),
                      _buildStatCell(row.wins.toString(), isDark),
                      _buildStatCell(row.draws.toString(), isDark),
                      _buildStatCell(row.losses.toString(), isDark),
                      // Points
                      SizedBox(
                        width: 40,
                        child: Text(
                          row.pts.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF006C35),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Legend
        _buildLegendItem(Colors.green, "دوري أبطال آسيا", isDark),
        const SizedBox(height: 8),
        _buildLegendItem(Colors.red, "الهبوط", isDark),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildStatCell(String value, bool isDark) {
    return SizedBox(
      width: 35,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, bool isDark) {
    return Row(
      children: [
        Container(width: 4, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[500] : Colors.grey[600]),
        ),
      ],
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
        );
      },
    );
  }

  Widget _buildTeamLogo(String url, double size) {
    if (url.isEmpty) return Icon(Icons.shield, size: size, color: Colors.grey);
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      placeholder: (context, url) => SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF006C35)),
      ),
      errorWidget: (context, url, error) => Icon(Icons.shield, size: size, color: Colors.grey),
    );
  }
}
