// lib/services/plant_service.dart
import '../config/api_config.dart';
import 'api_service.dart';

class PlantService {
  final ApiService _api = ApiService.instance;
  
  Future<Map<String, dynamic>> getPlantProgress(int userId) async {
    final response = await _api.get(
      ApiConfig.PLANT_GET,
      params: {'userId': userId.toString()},
    );
    return response;
  }
  
  Future<void> updatePlantProgress({
    required int userId,
    required double water,
    required double sunlight,
    required int stage,
    int? points,
    int? stars,
  }) async {
    await _api.post(ApiConfig.PLANT_UPDATE, {
      'userId': userId,
      'water': water,
      'sunlight': sunlight,
      'stage': stage,
      'points': points,
      'stars': stars,
    });
  }
  
  Future<void> resetPlant(int userId) async {
    await _api.post(ApiConfig.PLANT_RESET, {
      'userId': userId,
    });
  }
}