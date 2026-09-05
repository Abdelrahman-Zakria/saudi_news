part of 'settings_cubit.dart';

class SettingsState {
  final bool isDarkMode;
  final bool breakingNewsEnabled;
  final bool sportsNewsEnabled;
  final bool jobsNewsEnabled;
  final String language;

  const SettingsState({
    required this.isDarkMode,
    required this.breakingNewsEnabled,
    required this.sportsNewsEnabled,
    required this.jobsNewsEnabled,
    required this.language,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    bool? breakingNewsEnabled,
    bool? sportsNewsEnabled,
    bool? jobsNewsEnabled,
    String? language,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      breakingNewsEnabled: breakingNewsEnabled ?? this.breakingNewsEnabled,
      sportsNewsEnabled: sportsNewsEnabled ?? this.sportsNewsEnabled,
      jobsNewsEnabled: jobsNewsEnabled ?? this.jobsNewsEnabled,
      language: language ?? this.language,
    );
  }
}
