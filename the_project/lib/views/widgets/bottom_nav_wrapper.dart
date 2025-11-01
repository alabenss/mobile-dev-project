import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart'; // ✅ import your old file
import '../screens/homescreen/home_screen.dart';
import '../screens/habits.dart';
import '../screens/activities/activities.dart';
import '../themes/style_simple/colors.dart';
import 'app_bar.dart';

class BottomNavWrapper extends StatefulWidget {
  const BottomNavWrapper({super.key});

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int _navIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    HabitsScreen(),
    Placeholder(),
    Activities(),
    Placeholder(),
  ];

  void _onTap(int index) {
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
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
        body: _pages[_navIndex],
        bottomNavigationBar: BottomPillNav( // ✅ using your old file
          index: _navIndex,
          onTap: _onTap,
        ),
      ),
    );
  }
}
