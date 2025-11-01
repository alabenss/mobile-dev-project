import 'package:flutter/material.dart';
import 'views/widgets/bottom_nav_wrapper.dart';
import 'views/screens/habits.dart';          // <-- your file
import 'views/screens/journaling/journaling_screen.dart';  // <-- your file
import 'views/screens/homescreen/home_screen.dart';
import 'views/themes/style_simple/theme.dart'; 
import 'views/screens/stats_screen/stats_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavWrapper(), // ✅
    );
  }
}
