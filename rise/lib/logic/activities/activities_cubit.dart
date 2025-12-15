// lib/logic/activities/activities_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'activities_state.dart';
import '../../database/repo/activities_repo.dart';

class ActivitiesCubit extends Cubit<ActivitiesState> {
  final AbstractActivitiesRepo _repo;

  ActivitiesCubit(this._repo) : super(const ActivitiesState());

  Future<void> loadActivities() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _repo.getActivities();
      emit(state.copyWith(isLoading: false, activities: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
