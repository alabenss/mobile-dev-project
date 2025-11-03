import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database/db_helper.dart';
import 'package:sqflite/sqflite.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await DBHelper.database;

  // Clear all tables for a clean test (optional)
  await DBHelper.clearAll();

  // Add a sample user
  int userId = await db.insert('users', {
    'name': 'John Doe',
    'email': 'john@example.com',
    'totalPoints': 0,
  });
  print('✅ Added user with id: $userId');

  // Add sample habits
  final now = DateFormat('yyyy-MM-dd').format(DateTime.now());

  await db.insert('habits', {
    'userId': userId,
    'title': 'Morning Exercise',
    'description': 'Do a 20-minute workout every morning',
    'frequency': 'daily',
    'status': 'active',
    'createdDate': now,
    'lastUpdated': now,
    'points': 10,
  });

  await db.insert('habits', {
    'userId': userId,
    'title': 'Drink Water',
    'description': 'Drink 2 liters of water per day',
    'frequency': 'daily',
    'status': 'active',
    'createdDate': now,
    'lastUpdated': now,
    'points': 5,
  });

  print('✅ Added sample habits.');

  // Fetch and print all habits
  final habits = await db.query('habits');
  print('\n📋 Current Habits:');
  for (var habit in habits) {
    print(habit);
  }

  // Mark one habit as completed and update user points
  final habitToComplete = habits.first;
  final habitId = habitToComplete['id'] as int;
  final habitPoints = habitToComplete['points'] as int;

  await completeHabit(db, userId, habitId, habitPoints);

  print('\n🎯 Habit $habitId marked as completed!');
  final updatedUser =
      await db.query('users', where: 'id = ?', whereArgs: [userId]);
  print('🏅 Updated User Points: ${updatedUser.first['totalPoints']}');

  // Show final list of habits
  final updatedHabits = await db.query('habits');
  print('\n🔄 Updated Habits:');
  for (var habit in updatedHabits) {
    print(habit);
  }

  runApp(const TestApp());
}

// Helper function to complete a habit and update points
Future<void> completeHabit(Database db, int userId, int habitId, int points) async {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  await db.update(
    'habits',
    {'status': 'completed', 'lastUpdated': today},
    where: 'id = ?',
    whereArgs: [habitId],
  );

  await db.insert('transactions', {
    'userId': userId,
    'type': 'earn',
    'amount': points,
    'description': 'Completed habit $habitId',
    'date': today,
  });

  await db.rawUpdate(
    'UPDATE users SET totalPoints = totalPoints + ? WHERE id = ?',
    [points, userId],
  );
}

// Minimal UI just to run the app
class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            'Database Test Completed!\nCheck console output.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
