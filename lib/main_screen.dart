import 'package:flutter/material.dart';
import 'features/news/presentation/pages/home_screen.dart';
import 'features/directory/presentation/pages/directory_screen.dart';
import 'features/sports/presentation/pages/sports_screen.dart';
import 'features/jobs/presentation/pages/jobs_screen.dart';
import 'features/settings/presentation/pages/more_menu_screen.dart';
import 'core/widgets/app_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  final bool isDarkMode;

  const MainScreen({
    super.key,
    this.onThemeChanged,
    this.isDarkMode = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    const HomeScreen(),
    const DirectoryScreen(),
    const SportsScreen(),
    const JobsScreen(),
    MoreMenuScreen(
      onThemeChanged: widget.onThemeChanged,
      isDarkMode: widget.isDarkMode,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
