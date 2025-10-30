import 'package:flutter/material.dart';
import 'views/themes/style_simple/theme.dart';
import 'views/screens/homescreen/home_screen.dart';

void main() {
  runApp(const WellnessApp());
}

class WellnessApp extends StatelessWidget {
  const WellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wellness',
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
