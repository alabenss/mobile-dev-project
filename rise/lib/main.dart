import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:the_project/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';  // ✅ NEW

import 'logic/home/home_cubit.dart';
import 'logic/activities/activities_cubit.dart';
import 'logic/habits/habit_cubit.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/auth/auth_state.dart' as app_auth;
import 'logic/journal/journal_cubit.dart';
import 'logic/journal/daily_mood_cubit.dart';
import 'logic/locale/locale_cubit.dart';

import 'database/repo/home_repo.dart';
import 'database/repo/activities_repo.dart';
import 'database/repo/habit_repo.dart';
import 'database/repo/journal_repository.dart';
import 'database/repo/daily_mood_repository.dart';
import 'database/repo/articles_repo.dart';

import 'views/widgets/common/bottom_nav_wrapper.dart';
import 'views/wrappers/phone_lock_wrapper.dart';
import 'views/screens/settings/profile.dart';
import 'views/screens/settings/app_lock_screen.dart';
import 'views/screens/settings/language_selection_screen.dart';
import 'views/screens/auth/login_screen.dart';
import 'views/screens/auth/signup_screen.dart';
import 'views/screens/welcome_screens/welcome_screen.dart';
import 'views/screens/welcome_screens/welcome_provider.dart';
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

  // ============================================================
  // ✅ STEP 1: Initialize Supabase FIRST (before Firebase)
  // ============================================================
  try {
    await Supabase.initialize(
      url: 'https://ycwdtlehjnrpikenlpji.supabase.co',  // TODO: Replace with your Supabase project URL
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inljd2R0bGVoam5ycGlrZW5scGppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2NDQxMTUsImV4cCI6MjA4MzIyMDExNX0.ada24MOrDI-g7OznNSfcTvQ3_ghUFl4rufcMMWmeXOU',  // TODO: Replace with your Supabase anon key
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
      debug: true,  // Set to false in production
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Supabase initialization failed: $e');
    // Continue anyway - will show error in UI
  }

  // ============================================================
  // STEP 2: Initialize Firebase (keep your existing code)
  // ============================================================
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

  // ============================================================
  // STEP 3: Initialize repositories and run app
  // ============================================================
  try {
    final homeRepo = AbstractHomeRepo.getInstance();
    final activitiesRepo = AbstractActivitiesRepo.getInstance();
    final habitRepo = HabitRepository();
    final articlesRepo = ArticlesRepo();

    // Reschedule all habit notifications
    await habitRepo.rescheduleAllNotifications();
    print('Habit notifications rescheduled');

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
          
          // ✅ AuthCubit will now use Supabase auth
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit()..checkAuthStatus(),
          ),

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
                    onPressed: () async {
                      // Could trigger a restart or retry mechanism
                    },
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
// Update your main.dart MyApp class
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
          home: FutureBuilder<bool>(
            future: WelcomeProvider.shouldShowWelcome(),
            builder: (context, welcomeSnapshot) {
              // If still checking, show loading
              if (welcomeSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // If should show welcome screens
              if (welcomeSnapshot.hasData && welcomeSnapshot.data == true) {
                return WelcomeScreen(
                  onCompleted: () {
                    // User skipped welcome, go to login
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const AppEntryPoint(),
                      ),
                    );
                  },
                );
              }

              // Otherwise go to normal app flow
              return const AppEntryPoint();
            },
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

// NEW: Separate entry point for auth flow
class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        final lang = 'en'; // Get from locale cubit if needed
        
        if (state.isAuthenticated && state.user != null) {
          // Mark user as logged in (so welcome won't show again)
          WelcomeProvider.markUserLoggedIn();
          
          context.read<HomeCubit>().loadInitial(
                userName: state.user!.fullName,
                lang: lang,
              );

                context.read<HabitCubit>().loadHabits();
                context.read<ActivitiesCubit>().loadActivities();
              }
            },
            child: BlocBuilder<AuthCubit, app_auth.AuthState>(
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
    );
  }
}