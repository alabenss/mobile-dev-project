// lib/data/repo/home_repo.dart
import '../../services/api_service.dart';
import '../../config/api_config.dart';

// Simple model used by the repo
class HomeStatus {
  final int waterCount;
  final int waterGoal;
  final double detoxProgress;

  const HomeStatus({
    required this.waterCount,
    required this.waterGoal,
    required this.detoxProgress,
  });

  // Convert from API response
  factory HomeStatus.fromJson(Map<String, dynamic> json) {
    return HomeStatus(
      waterCount: json['water_count'] ?? 0,
      waterGoal: json['water_goal'] ?? 8,
      detoxProgress: (json['detox_progress'] ?? 0.0).toDouble(),
    );
  }

  // Convert to API request
  Map<String, dynamic> toJson() {
    return {
      'waterCount': waterCount,
      'waterGoal': waterGoal,
      'detoxProgress': detoxProgress,
    };
  }
}

// Abstract repo: Cubit talks to this, not directly to API
abstract class AbstractHomeRepo {
  Future<HomeStatus> loadTodayStatus();
  Future<void> saveStatus(HomeStatus status);
  Future<void> incrementWater();
  Future<void> decrementWater();
  Future<void> updateDetoxProgress(double progress);

  static AbstractHomeRepo getInstance() => _HomeRepoImpl();
}

class _HomeRepoImpl extends AbstractHomeRepo {
  final ApiService _api = ApiService.instance;

  String _getTodayString() {
    return _api.getTodayString();
  }

  @override
  Future<HomeStatus> loadTodayStatus() async {
    try {
      final userId = await _api.getCurrentUserId();
      final today = _getTodayString();

      print('HomeRepo: Loading status for userId: $userId, date: $today');

      final response = await _api.get(
        ApiConfig.HOME_STATUS_GET,
        params: {
          'userId': userId.toString(),
          'date': today,
        },
      );

      if (response['success'] == true && response['status'] != null) {
        return HomeStatus.fromJson(response['status']);
      }

      // Return default if not found
      return const HomeStatus(
        waterCount: 0,
        waterGoal: 8,
        detoxProgress: 0,
      );
    } catch (e) {
      print('HomeRepo: Error loading status: $e');
      // Return default values on error
      return const HomeStatus(
        waterCount: 0,
        waterGoal: 8,
        detoxProgress: 0,
      );
    }
  }

  @override
  Future<void> saveStatus(HomeStatus status) async {
    try {
      final userId = await _api.getCurrentUserId();
      final today = _getTodayString();

      print('HomeRepo: Saving status for userId: $userId, date: $today');

      await _api.post(
        ApiConfig.HOME_STATUS_SAVE,
        {
          'userId': userId,
          'date': today,
          'status': status.toJson(),
        },
      );

      print('HomeRepo: Status saved successfully');
    } catch (e) {
      print('HomeRepo: Error saving status: $e');
      rethrow;
    }
  }

  @override
  Future<void> incrementWater() async {
    try {
      final userId = await _api.getCurrentUserId();
      final today = _getTodayString();

      print('HomeRepo: Incrementing water for userId: $userId');

      await _api.post(
        ApiConfig.HOME_INCREMENT_WATER,
        {
          'userId': userId,
          'date': today,
        },
      );

      print('HomeRepo: Water incremented successfully');
    } catch (e) {
      print('HomeRepo: Error incrementing water: $e');
      rethrow;
    }
  }

  @override
  Future<void> decrementWater() async {
    try {
      final userId = await _api.getCurrentUserId();
      final today = _getTodayString();

      print('HomeRepo: Decrementing water for userId: $userId');

      await _api.post(
        ApiConfig.HOME_DECREMENT_WATER,
        {
          'userId': userId,
          'date': today,
        },
      );

      print('HomeRepo: Water decremented successfully');
    } catch (e) {
      print('HomeRepo: Error decrementing water: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateDetoxProgress(double progress) async {
    try {
      final userId = await _api.getCurrentUserId();
      final today = _getTodayString();

      print('HomeRepo: Updating detox progress to $progress');

      await _api.post(
        ApiConfig.HOME_UPDATE_DETOX,
        {
          'userId': userId,
          'date': today,
          'detoxProgress': progress,
        },
      );

      print('HomeRepo: Detox progress updated successfully');
    } catch (e) {
      print('HomeRepo: Error updating detox progress: $e');
      rethrow;
    }
  }
}