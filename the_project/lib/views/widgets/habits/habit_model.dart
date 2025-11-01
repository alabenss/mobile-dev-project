import 'package:flutter/material.dart';

class Habit {
  final String title;
  final String frequency;
  final IconData icon;
  final TimeOfDay? time;
  final bool reminder;
  bool done;

  Habit({
    required this.title,
    required this.icon,
    required this.frequency,
    this.time,
    this.reminder = false,
    this.done = false,
  });
}
