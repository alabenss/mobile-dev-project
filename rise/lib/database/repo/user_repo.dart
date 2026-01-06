// lib/data/repo/user_repo.dart
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class UserRepo {
  final ApiService _api = ApiService.instance;

  /// Get user stars
  Future<int> getUserStars(int userId) async {
    try {
      print('UserRepo: Getting stars for userId: $userId');

      final response = await _api.get(
        ApiConfig.USER_PROFILE,
        params: {'userId': userId.toString()},
      );

      if (response['success'] == true && response['user'] != null) {
        return response['user']['stars'] as int? ?? 0;
      }

      return 0;
    } catch (e) {
      print('UserRepo: Error getting user stars: $e');
      return 0;
    }
  }

  /// Update user stars
  Future<void> updateUserStars(int userId, int newStars) async {
    try {
      print('UserRepo: Updating stars for userId: $userId to $newStars');

      // You'll need to add this endpoint to your backend
      await _api.put('/user.updateStars', {
        'userId': userId,
        'stars': newStars,
      });

      print('UserRepo: Stars updated successfully');
    } catch (e) {
      print('UserRepo: Error updating user stars: $e');
      rethrow;
    }
  }

  /// Get user total points
  Future<int> getUserTotalPoints(int userId) async {
    try {
      print('UserRepo: Getting total points for userId: $userId');

      final response = await _api.get(
        ApiConfig.USER_PROFILE,
        params: {'userId': userId.toString()},
      );

      if (response['success'] == true && response['user'] != null) {
        return response['user']['total_points'] as int? ?? 0;
      }

      return 0;
    } catch (e) {
      print('UserRepo: Error getting user total points: $e');
      return 0;
    }
  }

  /// Update user total points
  Future<void> updateUserTotalPoints(int userId, int newPoints) async {
    try {
      print('UserRepo: Updating total points for userId: $userId to $newPoints');

      // You'll need to add this endpoint to your backend
      await _api.put('/user.updatePoints', {
        'userId': userId,
        'totalPoints': newPoints,
      });

      print('UserRepo: Total points updated successfully');
    } catch (e) {
      print('UserRepo: Error updating user total points: $e');
      rethrow;
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    try {
      print('UserRepo: Getting profile for userId: $userId');

      final response = await _api.get(
        ApiConfig.USER_PROFILE,
        params: {'userId': userId.toString()},
      );

      if (response['success'] == true && response['user'] != null) {
        return response['user'] as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      print('UserRepo: Error getting user profile: $e');
      return null;
    }
  }

  /// Update user name
  Future<void> updateUserName(int userId, String newName) async {
    try {
      print('UserRepo: Updating name for userId: $userId');

      await _api.put('/user.updateProfile', {
        'userId': userId,
        'name': newName,
      });

      print('UserRepo: Name updated successfully');
    } catch (e) {
      print('UserRepo: Error updating user name: $e');
      rethrow;
    }
  }

  /// Update user email
  Future<void> updateUserEmail(int userId, String newEmail) async {
    try {
      print('UserRepo: Updating email for userId: $userId');

      await _api.put('/user.updateProfile', {
        'userId': userId,
        'email': newEmail,
      });

      print('UserRepo: Email updated successfully');
    } catch (e) {
      print('UserRepo: Error updating user email: $e');
      rethrow;
    }
  }

  /// Update user password
  Future<void> updateUserPassword(int userId, String newPassword) async {
    try {
      print('UserRepo: Updating password for userId: $userId');

      await _api.put('/user.updatePassword', {
        'userId': userId,
        'password': newPassword,
      });

      print('UserRepo: Password updated successfully');
    } catch (e) {
      print('UserRepo: Error updating user password: $e');
      rethrow;
    }
  }
}