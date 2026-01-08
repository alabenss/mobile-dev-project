import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:the_project/l10n/app_localizations.dart';

import 'logic/home/home_cubit.dart';
import 'logic/activities/activities_cubit.dart';
import 'logic/habits/habit_cubit.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/auth/auth_state.dart';
import 'logic/journal/journal_cubit.dart';
import 'logic/journal/daily_mood_cubit.dart';
import 'logic/locale/locale_cubit.dart';

import 'database/repo/home_repo.dart';
import 'database/repo/activities_repo.dart';
import 'database/repo/habit_repo.dart';
import 'database/repo/journal_repository.dart';
import 'database/repo/daily_mood_repository.dart';

// ✅ NEW import
import 'database/repo/articles_repo.dart';

import 'views/widgets/common/bottom_nav_wrapper.dart';
import 'views/wrappers/phone_lock_wrapper.dart';
import 'views/screens/settings/profile.dart';
import 'views/screens/settings/app_lock_screen.dart';
import 'views/screens/settings/language_selection_screen.dart';
import 'views/screens/auth/login_screen.dart';
import 'views/screens/auth/signup_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'services/notification_service.dart';
import '/services/local_storage_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalStorageService.instance.initializeFolders();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService.instance.init(
    navigatorKey: navigatorKey,
    onTapAction: (screen) {
      if (screen == 'journal') {
        navigatorKey.currentState?.pushNamed('/home');
        bottomNavKey.currentState?.switchToTab(2);
      } else if (screen == 'home') {
        navigatorKey.currentState?.pushNamed('/home');
        bottomNavKey.currentState?.switchToTab(0);
      } else if (screen != null && screen.startsWith('habit_')) {
        navigatorKey.currentState?.pushNamed('/home');
        bottomNavKey.currentState?.switchToTab(1);
      }
    },
  );

  try {
    final homeRepo = AbstractHomeRepo.getInstance();
    final activitiesRepo = AbstractActivitiesRepo.getInstance();
    final habitRepo = HabitRepository();

    // ✅ NEW: Articles repo instance
    final articlesRepo = ArticlesRepo();

    // Reschedule all habit notifications
    await habitRepo.rescheduleAllNotifications();
    print('Habit notifications rescheduled');

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
          BlocProvider<AuthCubit>(create: (_) => AuthCubit()..checkAuthStatus()),

          // ✅ UPDATED: HomeCubit now needs ArticlesRepo
          BlocProvider<HomeCubit>(
            create: (_) => HomeCubit(homeRepo, habitRepo, articlesRepo),
          ),

          BlocProvider<ActivitiesCubit>(
            create: (_) => ActivitiesCubit(activitiesRepo)..loadActivities(),
          ),
          BlocProvider<HabitCubit>(
            create: (_) => HabitCubit(habitRepo)..loadHabits(),
          ),
          BlocProvider<JournalCubit>(
            create: (_) => JournalCubit(JournalRepository()),
          ),
          BlocProvider<DailyMoodCubit>(
            create: (_) => DailyMoodCubit(DailyMoodRepository()),
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('Error initializing app: $e');
    print('Stack trace: $stackTrace');

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'App initialization failed',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Error: $e',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {},
                    child: const Text('Retry'),
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

  String _langFromLocale(Locale? locale) {
    final code = locale?.languageCode ?? 'en';
    if (code == 'ar' || code == 'fr' || code == 'en') return code;
    return 'en';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        final lang = _langFromLocale(localeState.locale);

        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          locale: localeState.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
            Locale('ar'),
          ],
          home: BlocListener<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state.isAuthenticated && state.user != null) {
                context.read<HomeCubit>().loadInitial(
                      userName: state.user!.fullName,
                      lang: lang, // ✅ pass language to load correct articles
                    );

                context.read<HabitCubit>().loadHabits();
                context.read<ActivitiesCubit>().loadActivities();
              }
            },
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!state.isAuthenticated) {
                  return const LoginScreen();
                }

                return PhoneLockWrapper(
                  child: BottomNavWrapper(key: bottomNavKey),
                );
              },
            ),
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/home': (context) => BottomNavWrapper(key: bottomNavKey),
            '/profile': (context) => const ProfileScreen(),
            '/app-lock': (context) => const AppLockScreen(),
            '/language': (context) => const LanguageSelectionScreen(),
          },
        );
      },
    );
  }
}
