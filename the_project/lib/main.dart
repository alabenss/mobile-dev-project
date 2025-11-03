import 'package:flutter/material.dart';
import 'views/widgets/common/bottom_nav_wrapper.dart';
import 'views/screens/settings/profile.dart'; 

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
      },
    );
  }
}
