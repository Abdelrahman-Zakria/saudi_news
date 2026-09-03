import 'package:flutter/material.dart';
import '../../domain/entities/match.dart';
import '../../domain/entities/league_row.dart';
import 'package:saudi_news/features/news/domain/entities/article.dart';
import 'package:saudi_news/features/news/presentation/widgets/small_news_card.dart';
import '../../data/repositories/sports_repository_impl.dart';

class SportsScreen extends StatefulWidget {
  const SportsScreen({super.key});

  @override
  State<SportsScreen> createState() => _SportsScreenState();
}

class _SportsScreenState extends State<SportsScreen> {
  int _activeTab = 0; // 0: المباريات, 1: الترتيب, 2: الأخبار
  final _repository = SportsRepositoryImpl();

  final List<Match> _dummyMatches = [
    Match(
      id: "1",
      league: "دوري روشن السعودي",
      homeTeam: "الهلال",
      awayTeam: "النصر",
      homeScore: "3",
      awayScore: "0",
      homeLogo: "🔵",
      awayLogo: "🟡",
      status: "انتهت",
      time: "21:00",
      date: "2026-09-01",
    ),
    Match(
      id: "2",
      league: "دوري روشن السعودي",
      homeTeam: "الاتحاد",
      awayTeam: "الأهلي",
      homeScore: "0",
      awayScore: "0",
      homeLogo: "🟡",
      awayLogo: "🟢",
      status: "20:00",
      time: "20:00",
      date: "2026-09-02",
    ),
  ];

  final List<LeagueRow> _dummyLeagueTable = [
    LeagueRow(pos: 1, team: "الهلال", played: 20, wins: 18, draws: 2, losses: 0, pts: 56, logo: "🔵"),
    LeagueRow(pos: 2, team: "النصر", played: 20, wins: 15, draws: 2, losses: 3, pts: 47, logo: "🟡"),
    LeagueRow(pos: 3, team: "الاتحاد", played: 20, wins: 11, draws: 4, losses: 5, pts: 37, logo: "🟡"),
    LeagueRow(pos: 4, team: "الأهلي", played: 20, wins: 10, draws: 4, losses: 6, pts: 34, logo: "🟢"),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text("الرياضة - دوري روشن", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : Colors.black,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildToggle(context),
              Expanded(
                child: IndexedStack(
                  index: _activeTab,
                  children: [
                    _buildMatchesTab(isDark),
                    _buildStandingsTab(isDark),
                    _buildNewsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            _buildToggleItem(0, "📅 المباريات"),
            _buildToggleItem(1, "📊 الترتيب"),
            _buildToggleItem(2, "📰 الأخبار"),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(int index, String label) {
    final isSelected = _activeTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
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

  Widget _buildMatchesTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dummyMatches.length,
      itemBuilder: (context, index) {
        final match = _dummyMatches[index];
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

  Widget _buildStandingsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
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
          rows: _dummyLeagueTable.map((row) {
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
      ),
    );
  }

  Widget _buildNewsTab() {
    return StreamBuilder<List<Article>>(
      stream: _repository.getSportsUpdatesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF006C35)));
        }
        
        final articles = snapshot.data ?? [];
        if (articles.isEmpty) {
          return const Center(child: Text("لا توجد أخبار رياضية حالياً", style: TextStyle(color: Color(0xFF9CA3AF))));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          itemBuilder: (context, index) {
            return SmallNewsCard(
              article: articles[index],
              isFavorite: false,
              onFavorite: () {},
            );
          },
        );
      },
    );
  }
}
