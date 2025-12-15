import 'package:flutter/material.dart';
import 'package:the_project/l10n/app_localizations.dart';

class AppConfig {
  static final DateTime _startDate = DateTime(2024, 1, 1);

  static String quoteOfTheDay(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quotes = [
      l10n.quote1,
      l10n.quote2,
      l10n.quote3,
      l10n.quote4,
      l10n.quote5,
      l10n.quote6,
      l10n.quote7,
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final daysSinceStart = today.difference(_startDate).inDays;
    final index = daysSinceStart % quotes.length;

    return quotes[index];
  }
}
