import 'dart:async';

/// Global notifier for stats updates
/// Call StatsNotifier.instance.notify() whenever you update water, mood, or journal data
class StatsNotifier {
  static final StatsNotifier _instance = StatsNotifier._internal();
  static StatsNotifier get instance => _instance;

  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;

  StatsNotifier._internal();

  /// Call this method whenever data that affects stats is changed
  /// Examples: 
  /// - After adding/updating water count
  /// - After adding/updating mood
  /// - After creating/editing/deleting a journal entry
  void notify() {
    print('📊 StatsNotifier: Data changed, notifying listeners...');
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}

/// Usage examples:
/// 
/// After updating water count:
/// await DBHelper.updateWaterCount(userId, date, newCount);
/// StatsNotifier.instance.notify();
/// 
/// After adding a journal entry:
/// await DBHelper.insertJournal(journalData);
/// StatsNotifier.instance.notify();
/// 
/// After updating mood:
/// await DBHelper.updateMood(userId, date, moodData);
/// StatsNotifier.instance.notify();