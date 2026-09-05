import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'main_screen.dart';
import 'firebase_options.dart';
import 'core/services/settings_service.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/news/presentation/cubit/news_cubit.dart';
import 'features/jobs/presentation/cubit/jobs_cubit.dart';
import 'features/sports/presentation/cubit/sports_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final settingsService = SettingsService();
  await settingsService.init();
  
  await initializeDateFormatting('ar', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SettingsCubit()),
        BlocProvider(create: (context) => NewsCubit()..init()),
        BlocProvider(create: (context) => JobsCubit()..init()),
        BlocProvider(create: (context) => SportsCubit()..init()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'أخبار السعودية',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'SA'),
            ],
            locale: const Locale('ar', 'SA'),
            home: const MainScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
