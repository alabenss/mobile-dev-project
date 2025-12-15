import '../db_helper.dart';

class UserRepo {
  Future<int> getUserStars(int userId) async {
  final db = await DBHelper.database;
  final result = await db.query(
    'users',
    columns: ['stars'],
    where: 'id = ?',
    whereArgs: [userId],
  );

  return result.first['stars'] as int;
}

Future<void> updateUserStars(int userId, int newStars) async {
  final db = await DBHelper.database;
  await db.update(
    'users',
    {'stars': newStars},
    where: 'id = ?',
    whereArgs: [userId],
  );
}

}