import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'features/news/presentation/cubit/tech_news_cubit.dart';
import 'main_screen.dart';
import 'firebase_options.dart';
import 'core/services/settings_service.dart';
import 'core/services/notification_service.dart';
import 'core/cubit/connectivity_cubit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'core/widgets/no_internet_screen.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'features/news/presentation/cubit/news_cubit.dart';
import 'features/jobs/presentation/cubit/jobs_cubit.dart';
import 'features/sports/presentation/cubit/sports_cubit.dart';
import 'features/directory/presentation/cubit/directory_cubit.dart';
import 'features/news/presentation/cubit/favorites_cubit.dart';
import 'features/settings/presentation/cubit/notifications_cubit.dart';
import 'features/prayer/presentation/cubit/prayer_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  final settingsService = SettingsService();
  await settingsService.init();
  
  // Check connectivity before initializing notifications
  final connectivityResult = await Connectivity().checkConnectivity();
  if (!connectivityResult.contains(ConnectivityResult.none)) {
    final notificationService = NotificationService();
    await notificationService.init();
  }
  
  await initializeDateFormatting('ar', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ConnectivityCubit()),
        BlocProvider(create: (context) => SettingsCubit()),
        BlocProvider(create: (context) => NewsCubit()..init()),
        BlocProvider(create: (context) => TechNewsCubit()..init()),
        BlocProvider(create: (context) => JobsCubit()..init()),
        BlocProvider(create: (context) => SportsCubit()..init()),
        BlocProvider(create: (context) => DirectoryCubit()),
        BlocProvider(create: (context) => FavoritesCubit()),
        BlocProvider(create: (context) => NotificationsCubit()),
        BlocProvider(create: (context) => PrayerCubit()..init()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            title: 'أخبار السعودية',
            navigatorKey: navigatorKey,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar', 'SA'),
            ],
            locale: const Locale('ar', 'SA'),
            home: BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
              builder: (context, connectivityStatus) {
                if (connectivityStatus == ConnectivityStatus.disconnected) {
                  return const NoInternetScreen();
                }
                return const MainScreen();
              },
            ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
