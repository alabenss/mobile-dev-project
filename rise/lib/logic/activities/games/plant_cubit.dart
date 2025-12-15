import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../database/db_helper.dart';
import 'plant_state.dart';

class PlantCubit extends Cubit<PlantState> {
  PlantCubit() : super(const PlantState());

  static const int _waterCost = 30;
  static const int _sunCost = 25;
  static const double _step = 0.2;   // 20% per action
  static const int _maxStage = 3;    // After this → reset + give star

  // Load user progress
  Future<void> loadInitial() async {
    final prefs = await SharedPreferences.getInstance();

    final userId =
        prefs.getInt('userId') ?? await DBHelper.ensureDefaultUser();

    final stars = await DBHelper.getUserStars(userId);

    final points = await _getUserPoints(userId);

    final water = prefs.getDouble('plant_water_$userId') ?? 0.0;
    final sunlight = prefs.getDouble('plant_sunlight_$userId') ?? 0.0;
    final stage = prefs.getInt('plant_stage_$userId') ?? 0;

    emit(state.copyWith(
      availablePoints: points,
      water: water,
      sunlight: sunlight,
      stage: stage,
      stars: stars,
    ));
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
    int stage = state.stage;
    int stars = state.stars;
    double w = water;
    double s = sunlight;
    final prefs = await SharedPreferences.getInstance();
    final userId =
        prefs.getInt('userId') ?? await DBHelper.ensureDefaultUser();

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
        await DBHelper.updateUserStars(userId, stars);
        stage = 0;        // Reset plant to start
        w = 0.0;
        s = 0.0;
      }
    }

    emit(state.copyWith(
      availablePoints: newPoints,
      water: w,
      sunlight: s,
      stage: stage,
      stars: stars,
    ));

    // Persist
    await _setUserPoints(newPoints);
    await _savePlantProgress(w, s, stage, stars);
    
  }

  // -------------------------------------------------------
  // DATABASE / STORAGE
  // -------------------------------------------------------

  Future<int> _getUserPoints(int userId) async {
    final db = await DBHelper.database;
    final result = await db.query(
      'users',
      columns: ['totalPoints'],
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final value = result.first['totalPoints'];
      if (value is int) return value;
      if (value is num) return value.toInt();
    }
    return 0;
  }

  Future<void> _setUserPoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    final userId =
        prefs.getInt('userId') ?? await DBHelper.ensureDefaultUser();

    final db = await DBHelper.database;
    await db.update(
      'users',
      {'totalPoints': points},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> _savePlantProgress(
      double water, double sunlight, int stage, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final userId =
        prefs.getInt('userId') ?? await DBHelper.ensureDefaultUser();

    await prefs.setDouble('plant_water_$userId', water);
    await prefs.setDouble('plant_sunlight_$userId', sunlight);
    await prefs.setInt('plant_stage_$userId', stage);
    await prefs.setInt('plant_stars_$userId', stars);
  }
}
