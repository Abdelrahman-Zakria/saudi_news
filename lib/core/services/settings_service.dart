import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme
  bool get isDarkMode => _prefs.getBool('isDarkMode') ?? false;
  Future<void> setDarkMode(bool value) async => await _prefs.setBool('isDarkMode', value);

  // Notifications
  bool get breakingNewsEnabled => _prefs.getBool('breakingNews') ?? true;
  Future<void> setBreakingNews(bool value) async => await _prefs.setBool('breakingNews', value);

  bool get sportsNewsEnabled => _prefs.getBool('sportsNews') ?? true;
  Future<void> setSportsNews(bool value) async => await _prefs.setBool('sportsNews', value);

  bool get jobsNewsEnabled => _prefs.getBool('jobsNews') ?? true;
  Future<void> setJobsNews(bool value) async => await _prefs.setBool('jobsNews', value);

  // Language
  String get language => _prefs.getString('language') ?? 'العربية';
  Future<void> setLanguage(String value) async => await _prefs.setString('language', value);

  // Contacts Sync
  bool get contactsSynced => _prefs.getBool('contactsSynced') ?? false;
  Future<void> setContactsSynced(bool value) async => await _prefs.setBool('contactsSynced', value);

  // Favorites
  List<String> get favoriteIds => _prefs.getStringList('favoriteIds') ?? [];
  Future<void> setFavoriteIds(List<String> ids) async => await _prefs.setStringList('favoriteIds', ids);

  List<String> getCachedFavoriteArticles() => _prefs.getStringList('cachedArticles') ?? [];
  Future<void> setCachedFavoriteArticles(List<String> data) async => await _prefs.setStringList('cachedArticles', data);
}
