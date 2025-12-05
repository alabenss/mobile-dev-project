import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'logic/home/home_cubit.dart';
import 'logic/activities/activities_cubit.dart';
import 'logic/habits/habit_cubit.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/auth/auth_state.dart';

import 'database/repo/home_repo.dart';
import 'database/repo/activities_repo.dart';
import 'database/repo/habit_repo.dart';
import 'database/db_helper.dart';

import 'views/widgets/common/bottom_nav_wrapper.dart';
import 'views/screens/settings/profile.dart';
import 'views/screens/settings/app_lock_screen.dart';
import 'views/screens/auth/login_screen.dart';
import 'views/screens/auth/signup_screen.dart';

import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize database
    print('Initializing database...');
    final db = await DBHelper.database;
    print('Database initialized at: ${db.path}');
    
    // Create demo data
    print('Creating demo data...');
    await DBHelper.initializeDemoData();
    print('Demo data created successfully');
    
    // Verify data was created
    final userCount = await db.rawQuery('SELECT COUNT(*) as c FROM users');
    print('User count: ${userCount.first['c']}');
    
    final homeRepo = AbstractHomeRepo.getInstance();
    final activitiesRepo = AbstractActivitiesRepo.getInstance();
    final habitRepo = HabitRepository();

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit()..checkAuthStatus(),
          ),
          BlocProvider<HomeCubit>(
            create: (_) => HomeCubit(homeRepo, habitRepo),
          ),
          BlocProvider<ActivitiesCubit>(
            create: (_) => ActivitiesCubit(activitiesRepo)..loadActivities(),
          ),
          BlocProvider<HabitCubit>(
            create: (_) => HabitCubit(habitRepo)..loadHabits(),
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('Error initializing app: $e');
    print('Stack trace: $stackTrace');
    
    // Show error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 20),
                  Text(
                    'App initialization failed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Error: $e',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Try to clear and reinitialize
                      try {
                        await DBHelper.clearAll();
                        await DBHelper.initializeDemoData();
                      } catch (_) {}
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      
      // Add localizations
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('fr', ''),
      ],
      
      home: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          // When user logs in, load their data
          if (state.isAuthenticated && state.user != null) {
            print('User authenticated: ${state.user!.name}');
            context.read<HomeCubit>().loadInitial(userName: state.user!.name);
            context.read<HabitCubit>().loadHabits();
            context.read<ActivitiesCubit>().loadActivities();
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            // Show login screen if not authenticated
            if (!state.isAuthenticated) {
              return const LoginScreen();
            }
            
            // Show main app if authenticated
            return const BottomNavWrapper();
          },
        ),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const BottomNavWrapper(),
        '/profile': (context) => const ProfileScreen(),
        '/app-lock': (context) => const AppLockScreen(),
      },
    );
  }
}