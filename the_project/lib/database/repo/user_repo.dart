import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db_helper.dart';
import '../../models/user_model.dart';

class UserRepo {
  Future<int> getUserStars(int userId) async {
  final db = await DBHelper.database;;
  final result = await db.query(
    'users',
    columns: ['stars'],
    where: 'id = ?',
    whereArgs: [userId],
  );

  return result.first['stars'] as int;
}

Future<void> updateUserStars(int userId, int newStars) async {
  final db = await DBHelper.database;;
  await db.update(
    'users',
    {'stars': newStars},
    where: 'id = ?',
    whereArgs: [userId],
  );
}

}