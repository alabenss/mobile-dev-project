import 'package:flutter/material.dart';
import 'views/widgets/common/bottom_nav_wrapper.dart';
import 'views/screens/settings/profile.dart'; // 👈 import your new profile screen
import 'views/screens/settings/app_lock_screen.dart';
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

      
      routes: {
        '/profile': (context) => const ProfileScreen(),
        '/app-lock': (context) => const AppLockScreen(), 
      },
    );
  }
}
