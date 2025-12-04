class AppConfig {
  // 1) Put all your quotes here
  static const List<String> quotes = [
    'The best way to predict the future is to create it',
    'You are stronger than you think.',
    'Small steps every day lead to big changes.',
    'You don’t have to be perfect to be amazing.',
    'Believe you can and you’re halfway there.',
    'If you want to live a happy life, tie it to a goal, not to people or things.',
    'The only way to do great work is to love what you do.',
    // add as many as you like
  ];

  // 2) Start date for your rotation (can be any fixed day)
  static final DateTime _startDate = DateTime(2024, 1, 1);

  // 3) Public getter used by the UI
  static String get quoteOfTheDay {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final daysSinceStart = today.difference(_startDate).inDays;
    // Make sure index stays within the list range
    final index = daysSinceStart % quotes.length;

    return quotes[index];
  }
}
