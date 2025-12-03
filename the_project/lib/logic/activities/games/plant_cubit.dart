import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../database/db_helper.dart';
import 'plant_state.dart';

class PlantCubit extends Cubit<PlantState> {
  PlantCubit() : super(const PlantState());

  // Load initial points from DB
  Future<void> loadInitial() async {
    final points = await DBHelper.getUserTotalPoints();
    emit(state.copyWith(availablePoints: points));
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

    // persist new total points
    await DBHelper.setUserTotalPoints(newPoints);
  }
}
