import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/settings_service.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsService _settingsService = SettingsService();

  SettingsCubit()
      : super(SettingsState(
          isDarkMode: SettingsService().isDarkMode,
          breakingNewsEnabled: SettingsService().breakingNewsEnabled,
          sportsNewsEnabled: SettingsService().sportsNewsEnabled,
          jobsNewsEnabled: SettingsService().jobsNewsEnabled,
          language: SettingsService().language,
        ));

  Future<void> toggleTheme(bool isDark) async {
    await _settingsService.setDarkMode(isDark);
    emit(state.copyWith(isDarkMode: isDark));
  }

  Future<void> setBreakingNews(bool enabled) async {
    await _settingsService.setBreakingNews(enabled);
    emit(state.copyWith(breakingNewsEnabled: enabled));
  }

  Future<void> setSportsNews(bool enabled) async {
    await _settingsService.setSportsNews(enabled);
    emit(state.copyWith(sportsNewsEnabled: enabled));
  }

  Future<void> setJobsNews(bool enabled) async {
    await _settingsService.setJobsNews(enabled);
    emit(state.copyWith(jobsNewsEnabled: enabled));
  }

  Future<void> setLanguage(String language) async {
    await _settingsService.setLanguage(language);
    emit(state.copyWith(language: language));
  }
}
