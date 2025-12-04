// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:the_project/l10n/app_localizations.dart';

import 'logic/home/home_cubit.dart';
import 'logic/activities/activities_cubit.dart';

import 'database/repo/home_repo.dart';
import 'database/repo/activities_repo.dart';

import 'views/widgets/common/bottom_nav_wrapper.dart';
import 'views/screens/settings/profile.dart';
import 'views/screens/settings/app_lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final homeRepo = AbstractHomeRepo.getInstance();
  final activitiesRepo = AbstractActivitiesRepo.getInstance();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (_) => HomeCubit(homeRepo)..loadInitial(),
        ),
        BlocProvider<ActivitiesCubit>(
          create: (_) => ActivitiesCubit(activitiesRepo)..loadActivities(),
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

      // 🔹 Force French for your audience (can be dynamic later)
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const BottomNavWrapper(),
      routes: {
        '/profile': (context) => const ProfileScreen(),
        '/app-lock': (context) => const AppLockScreen(),
      },
    );
  }
}
