import 'package:flutter/material.dart';
import 'views/widgets/bottom_nav_wrapper.dart';
// <-- your file
// <-- your file

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
