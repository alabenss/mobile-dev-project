class User {
  final int id;
  final String name;
  final String email;
  final int totalPoints;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.totalPoints,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      totalPoints: map['totalPoints'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'totalPoints': totalPoints,
    };
  }
}