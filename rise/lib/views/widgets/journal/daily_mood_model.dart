class DailyMoodModel {
  final int? id;
  final int userId;
  final DateTime date;
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

  DailyMoodModel copyWith({
    int? id,
    int? userId,
    DateTime? date,
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': _formatDate(date),
      'moodImage': moodImage,
      'moodLabel': moodLabel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DailyMoodModel.fromMap(Map<String, dynamic> map) {
    return DailyMoodModel(
      id: map['id'] as int?,
      userId: map['userId'] as int,
      date: _parseDate(map['date'] as String),
      moodImage: map['moodImage'] as String,
      moodLabel: map['moodLabel'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  // Format date as YYYY-MM-DD for database storage
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}