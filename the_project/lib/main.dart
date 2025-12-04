import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'logic/home/home_cubit.dart';
import 'logic/activities/activities_cubit.dart';
import 'logic/habits/habit_cubit.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/auth/auth_state.dart';

import 'database/repo/home_repo.dart';
import 'database/repo/activities_repo.dart';
import 'database/repo/habit_repo.dart';

import 'views/widgets/common/bottom_nav_wrapper.dart';
import 'views/screens/settings/profile.dart';
import 'views/screens/settings/app_lock_screen.dart';
import 'views/screens/auth/login_screen.dart';
import 'views/screens/auth/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
          create: (_) => HomeCubit(homeRepo)..loadInitial(),
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthCubit, AuthState>(
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