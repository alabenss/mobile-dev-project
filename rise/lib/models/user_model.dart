class User {
  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final int totalPoints;
  final int stars;
  final String? createdAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.totalPoints,
    required this.stars,
    this.createdAt,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      firstName: map['first_name'] as String? ?? '',
      lastName: map['last_name'] as String? ?? '',
      username: map['username'] as String? ?? '',
      email: map['email'] as String? ?? '',
      totalPoints: map['total_points'] as int? ?? 0,
      stars: map['stars'] as int? ?? 0,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'total_points': totalPoints,
      'stars': stars,
      'created_at': createdAt,
    };
  }
}