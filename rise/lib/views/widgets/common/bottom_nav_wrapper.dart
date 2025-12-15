import 'package:flutter/material.dart';

import 'bottom_nav_bar.dart';
import 'app_bar.dart';

import '../../screens/homescreen/home_screen.dart';
import '../../screens/journaling/journaling_screen.dart';
import '../../screens/habits/habits_screen.dart';
import '../../screens/activities/activities.dart';
import '../../screens/statistics/stats_screen.dart';
import '../../themes/style_simple/colors.dart';

final GlobalKey<_BottomNavWrapperState> bottomNavKey =
    GlobalKey<_BottomNavWrapperState>();

class BottomNavWrapper extends StatefulWidget {
  const BottomNavWrapper({super.key});

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int _navIndex = 0;

  /// Used from notifications to jump to a specific tab:
  /// 0=Home, 1=Habits, 2=Journal, 3=Activities, 4=Stats
  void switchToTab(int index) {
    if (index < 0 || index > 4) return;
    setState(() => _navIndex = index);
  }

  void _onTap(int index) {
    setState(() => _navIndex = index);
  }

  // used by HomeScreen callback
  void switchToHabitsTab() {
    setState(() => _navIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(onViewAllHabits: switchToHabitsTab),
      const HabitsScreen(),
      const JournalingScreen(),
      const Activities(),
      const StatsScreen(),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(),
        body: pages[_navIndex],
        bottomNavigationBar: BottomPillNav(
          index: _navIndex,
          onTap: _onTap,
        ),
      ),
    );
  }
}
