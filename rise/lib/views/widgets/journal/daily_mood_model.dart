// lib/views/widgets/journal/daily_mood_model.dart

class DailyMoodModel {
  final int? id;
  final int userId;
  final String date;  // This should be just YYYY-MM-DD (date only)
  final String moodImage;
  final String moodLabel;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyMoodModel({
    this.id,
    required this.userId,
    required this.date,
    required this.moodImage,
    required this.moodLabel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyMoodModel.fromMap(Map<String, dynamic> map) {
    try {
      // Parse dates safely
      DateTime parseDateTime(dynamic value) {
        if (value == null) return DateTime.now().toUtc();
        if (value is DateTime) return value.toUtc();
        if (value is String) {
          // If it ends with 'Z', it's UTC, parse as UTC and convert to local
          if (value.endsWith('Z')) {
            return DateTime.parse(value).toLocal();
          } else {
            // No timezone indicator, assume UTC and convert to local
            return DateTime.parse('${value}Z').toLocal();
          }
        }
        return DateTime.now().toUtc();
      }

      return DailyMoodModel(
        id: map['id'] as int?,
        userId: map['user_id'] as int,
        date: map['date'] as String,  // This is just "YYYY-MM-DD"
        moodImage: map['mood_image'] as String,
        moodLabel: map['mood_label'] as String,
        createdAt: parseDateTime(map['created_at']),
        updatedAt: parseDateTime(map['updated_at']),
      );
    } catch (e) {
      print('❌ Error parsing DailyMoodModel: $e');
      print('📦 Raw map data: $map');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'mood_image': moodImage,
      'mood_label': moodLabel,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  DailyMoodModel copyWith({
    int? id,
    int? userId,
    String? date,
    String? moodImage,
    String? moodLabel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyMoodModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      moodImage: moodImage ?? this.moodImage,
      moodLabel: moodLabel ?? this.moodLabel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DailyMoodModel(id: $id, userId: $userId, date: $date, moodLabel: $moodLabel, moodImage: $moodImage)';
  }
}