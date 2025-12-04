import 'package:flutter/material.dart';

class Habit {
  final String title;
  final String frequency;
  final IconData icon;
  final TimeOfDay? time;
  final bool reminder;
  final int points; // ADD THIS LINE
  bool done;
  bool skipped;

  Habit({
    required this.title,
    required this.icon,
    required this.frequency,
    this.time,
    this.reminder = false,
    this.points = 10, // ADD THIS LINE with default value
    this.done = false,
    this.skipped = false,
  });
}