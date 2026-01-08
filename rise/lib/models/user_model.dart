class User {
  final int id;
  final String name;
  final String email;
  final int totalPoints;
  final int stars;
  final String? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.totalPoints,
    required this.stars,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      totalPoints: map['total_points'] as int? ?? 0,
      stars: map['stars'] as int? ?? 0,
      createdAt: map['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'total_points': totalPoints,
      'stars':stars,
      'createdAt': createdAt,
    };
  }
}