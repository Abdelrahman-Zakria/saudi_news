import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saudi_news/features/news/domain/entities/article.dart';
import 'package:saudi_news/features/news/data/models/article_model.dart';
import '../../domain/entities/match.dart';
import '../../domain/entities/league_row.dart';
import '../utils/team_mapper.dart';
import 'package:intl/intl.dart';

class SportsRepositoryImpl {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Article>> getSportsUpdates({int limit = 10}) async {
    final snapshot = await _firestore
        .collection('spl')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
        
    return snapshot.docs.map((doc) => ArticleModel.fromFirestore(doc)).toList();
  }

  Future<List<Match>> getMatches() async {
    try {
      final response = await http.get(Uri.parse('https://site.api.espn.com/apis/site/v2/sports/soccer/ksa.1/scoreboard'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List events = data['events'] ?? [];
        
        return events.map((e) {
          final List competitions = e['competitions'] ?? [];
          final comp = competitions.first;
          final List competitors = comp['competitors'] ?? [];
          
          final home = competitors.firstWhere((c) => c['homeAway'] == 'home');
          final away = competitors.firstWhere((c) => c['homeAway'] == 'away');
          
          final homeTeam = home['team'];
          final awayTeam = away['team'];
          
          final status = comp['status'] ?? {};
          final state = status['type']?['state'] ?? 'pre';
          
          String statusText = "مجدولة";
          if (state == 'in') {
            statusText = "جارية - ${status['displayClock']}";
          } else if (state == 'post') {
            statusText = "انتهت";
          }

          final date = DateTime.parse(e['date']).toLocal();
          
          return Match(
            id: e['id'] ?? '',
            league: "دوري روشن السعودي",
            homeTeam: TeamMapper.toArabic(homeTeam['displayName'] ?? ''),
            awayTeam: TeamMapper.toArabic(awayTeam['displayName'] ?? ''),
            homeScore: home['score'] ?? '0',
            awayScore: away['score'] ?? '0',
            homeLogo: homeTeam['logo'] ?? '',
            awayLogo: awayTeam['logo'] ?? '',
            status: statusText,
            time: DateFormat('HH:mm').format(date),
            date: DateFormat('yyyy-MM-dd').format(date),
          );
        }).toList();
      }
    } catch (e) {
      print("Error fetching matches: $e");
    }
    return [];
  }

  Future<List<LeagueRow>> getStandings() async {
    try {
      final response = await http.get(Uri.parse('https://site.api.espn.com/apis/v2/sports/soccer/ksa.1/standings'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List children = data['children'] ?? [];
        if (children.isEmpty) return [];
        
        final List entries = children.first['standings']?['entries'] ?? [];
        
        return entries.map((e) {
          final team = e['team'];
          final List stats = e['stats'] ?? [];
          
          int getStat(String name) => stats.firstWhere((s) => s['name'] == name, orElse: () => {'value': 0})['value'].toInt();

          return LeagueRow(
            pos: getStat('rank'),
            team: TeamMapper.toArabic(team['displayName'] ?? ''),
            played: getStat('gamesPlayed'),
            wins: getStat('wins'),
            draws: getStat('ties'),
            losses: getStat('losses'),
            pts: getStat('points'),
            logo: team['logos'] != null && team['logos'].isNotEmpty ? team['logos'].first['href'] : '',
          );
        }).toList();
      }
    } catch (e) {
      print("Error fetching standings: $e");
    }
    return [];
  }
}
