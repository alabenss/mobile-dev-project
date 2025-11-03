import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import '../screens/homescreen/home_screen.dart';
import '../screens/journaling/journaling_screen.dart';
import '../screens/habits_screen.dart';
import '../screens/activities/activities.dart';
import '../themes/style_simple/colors.dart';
import '../screens/stats_screen/stats_screen.dart';
import 'app_bar.dart';

class BottomNavWrapper extends StatefulWidget {
  const BottomNavWrapper({super.key});

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int _navIndex = 0;

  void _onTap(int index) {
    setState(() => _navIndex = index);
  }

  /// ✅ public method to allow child widgets to switch tabs
  void switchToHabitsTab() {
    setState(() => _navIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        onViewAllHabits: switchToHabitsTab, // pass callback to HomeScreen
      ),
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
