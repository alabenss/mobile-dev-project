import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'plant_state.dart';
import '../../../services/api_service.dart';
import '../../../config/api_config.dart';


class PlantCubit extends Cubit<PlantState> {
  PlantCubit() : super(const PlantState());

  final ApiService _api = ApiService.instance;

  static const int _waterCost = 30;
  static const int _sunCost = 25;
  static const double _step = 0.2;   // 20% per action
  static const int _maxStage = 3;    // After this → reset + give star

  /// Get current user ID
  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  /// Load user progress from backend
  Future<void> loadInitial() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        print('PlantCubit: No user logged in');
        return;
      }

      // Get plant progress from backend
      final response = await _api.get(
        ApiConfig.PLANT_GET,
        params: {'userId': userId.toString()},
      );

      if (response['success'] == true) {
        final plant = response['plant'];
        final points = response['points'] as int? ?? 0;
        final stars = response['stars'] as int? ?? 0;

        emit(state.copyWith(
          availablePoints: points,
          water: (plant['water'] as num?)?.toDouble() ?? 0.0,
          sunlight: (plant['sunlight'] as num?)?.toDouble() ?? 0.0,
          stage: plant['stage'] as int? ?? 0,
          stars: stars,
        ));
      }
    } catch (e) {
      print('PlantCubit: Error loading initial data: $e');
    }
  }

  // -------------------------------------------------------
  // ACTIONS
  // -------------------------------------------------------

  Future<void> spendWater() async {
    if (state.availablePoints < _waterCost || state.water >= 1.0) return;

    final newPoints = state.availablePoints - _waterCost;
    final newWater = (state.water + _step).clamp(0.0, 1.0);

    await _applyProgress(newPoints, newWater, state.sunlight);
  }

  Future<void> spendSun() async {
    if (state.availablePoints < _sunCost || state.sunlight >= 1.0) return;

    final newPoints = state.availablePoints - _sunCost;
    final newSun = (state.sunlight + _step).clamp(0.0, 1.0);

    await _applyProgress(newPoints, state.water, newSun);
  }

  // -------------------------------------------------------
  // CORE PROGRESS LOGIC
  // -------------------------------------------------------

  Future<void> _applyProgress(
      int newPoints, double water, double sunlight) async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      int stage = state.stage;
      int stars = state.stars;
      double w = water;
      double s = sunlight;

      // When both bars full → stage up
      if (w >= 1.0 && s >= 1.0) {
        // If not max stage → normal growth
        if (stage < _maxStage) {
          stage += 1;
          w = 0.0;
          s = 0.0;
        } else {
          // Max stage reached → reward + reset
          stars += 1;       // ⭐ Give user a star
          stage = 0;        // Reset plant to start
          w = 0.0;
          s = 0.0;
        }
      }

      // Update state
      emit(state.copyWith(
        availablePoints: newPoints,
        water: w,
        sunlight: s,
        stage: stage,
        stars: stars,
      ));

      // Save to backend
      await _api.post(ApiConfig.PLANT_UPDATE, {
        'userId': userId,
        'water': w,
        'sunlight': s,
        'stage': stage,
        'points': newPoints,
        'stars': stars,
      });

      print('PlantCubit: Progress saved to backend');
    } catch (e) {
      print('PlantCubit: Error applying progress: $e');
    }
  }

  /// Reset plant progress
  Future<void> resetPlant() async {
    try {
      final userId = await _getCurrentUserId();
      if (userId == null) return;

      await _api.post(ApiConfig.PLANT_RESET, {
        'userId': userId,
      });

      emit(state.copyWith(
        water: 0.0,
        sunlight: 0.0,
        stage: 0,
      ));

      print('PlantCubit: Plant reset');
    } catch (e) {
      print('PlantCubit: Error resetting plant: $e');
    }
  }
}