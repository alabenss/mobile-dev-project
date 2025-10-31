// main.dart
import 'package:flutter/material.dart';
import 'views/themes/style_simple/theme.dart';
import 'views/screens/activities/activities.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BoostYourMoodScreen(), // 👈 start here to preview
    );
  }
}
