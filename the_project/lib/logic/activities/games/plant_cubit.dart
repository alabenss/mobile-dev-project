import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../../database/db_helper.dart';
import 'plant_state.dart';

class PlantCubit extends Cubit<PlantState> {
  PlantCubit() : super(const PlantState());

  // Load initial points and plant progress from storage
  Future<void> loadInitial() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get current user ID
    final userId = prefs.getInt('userId') ?? await DBHelper.ensureDefaultUser();
    
    // Get points for the logged-in user
    final points = await _getUserPoints(userId);
    
    // Load saved plant progress for this user
    final water = prefs.getDouble('plant_water_$userId') ?? 0.0;
    final sunlight = prefs.getDouble('plant_sunlight_$userId') ?? 0.0;
    final stage = prefs.getInt('plant_stage_$userId') ?? 0;
    
    emit(state.copyWith(
      availablePoints: points,
      water: water,
      sunlight: sunlight,
      stage: stage,
    ));
  }

  static const int _waterCost = 5;
  static const int _sunCost = 4;
  static const double _step = 0.2; // each action adds 20%

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

  Future<void> _applyProgress(
    int newPoints,
    double water,
    double sunlight,
  ) async {
    var stage = state.stage;
    var w = water;
    var s = sunlight;

    // If both full → grow stage, reset meters
    if (w >= 1.0 && s >= 1.0) {
      stage = stage + 1;
      w = 0.0;
      s = 0.0;
    }

    emit(state.copyWith(
      availablePoints: newPoints,
      water: w,
      sunlight: s,
      stage: stage,
    ));

    // Persist everything
    await _setUserPoints(newPoints);
    await _savePlantProgress(w, s, stage);
  }

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
    final userId = prefs.getInt('userId') ?? await DBHelper.ensureDefaultUser();
    
    final db = await DBHelper.database;
    await db.update(
      'users',
      {'totalPoints': points},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> _savePlantProgress(double water, double sunlight, int stage) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? await DBHelper.ensureDefaultUser();
    
    await prefs.setDouble('plant_water_$userId', water);
    await prefs.setDouble('plant_sunlight_$userId', sunlight);
    await prefs.setInt('plant_stage_$userId', stage);
  }
}