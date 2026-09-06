import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saudi_news/features/news/presentation/pages/home_screen.dart';
import 'package:saudi_news/features/jobs/presentation/pages/jobs_screen.dart';
import 'package:saudi_news/features/sports/presentation/pages/sports_screen.dart';
import 'package:saudi_news/features/directory/presentation/pages/directory_screen.dart';
import 'package:saudi_news/features/settings/presentation/pages/more_menu_screen.dart';
import 'package:saudi_news/core/widgets/app_bottom_nav.dart';
import 'package:saudi_news/core/widgets/app_header.dart';
import 'package:saudi_news/features/directory/presentation/cubit/directory_cubit.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Trigger contacts sync ONLY when the user manually opens the Directory tab (index 1)
    if (index == 1) {
      context.read<DirectoryCubit>().syncUserContacts();
    }
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return "أخبار السعودية";
      case 1:
        return "دليل الهاتف";
      case 2:
        return "الرياضة";
      case 3:
        return "الوظائف";
      case 4:
        return "المزيد";
      default:
        return "أخبار السعودية";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      const DirectoryScreen(),
      const SportsScreen(),
      const JobsScreen(),
      MoreMenuScreen(
        onTabChange: _onTabChanged,
      ),
    ];

    return Scaffold(
      appBar: AppHeader(title: _getTitle()),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}
