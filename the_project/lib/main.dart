import 'package:flutter/material.dart';
import 'views/widgets/bottom_nav_wrapper.dart';
import 'views/screens/profile.dart'; // 👈 import your new profile screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      home: const BottomNavWrapper(),

      // 👇 Register your routes here
      routes: {
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
