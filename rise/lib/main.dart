import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'l10n/app_localizations.dart';

import 'logic/home/home_cubit.dart';
import 'logic/activities/activities_cubit.dart';
import 'logic/habits/habit_cubit.dart';
import 'logic/auth/auth_cubit.dart';
import 'logic/auth/auth_state.dart' as app_auth;
import 'logic/journal/journal_cubit.dart';
import 'logic/journal/daily_mood_cubit.dart';
import 'logic/locale/locale_cubit.dart';
import 'logic/applock/app_lock_cubit.dart';

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

import 'services/notification_service.dart';
import 'services/local_storage_service.dart';

// Make sure this exists in your project (it seems you already have it)
import 'views/widgets/common/bottom_nav_wrapper.dart' show bottomNavKey;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Supabase first
    await Supabase.initialize(
      url: 'https://ycwdtlehjnrpikenlpji.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inljd2R0bGVoam5ycGlrZW5scGppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2NDQxMTUsImV4cCI6MjA4MzIyMDExNX0.ada24MOrDI-g7OznNSfcTvQ3_ghUFl4rufcMMWmeXOU',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
      debug: true,
    );

    // ✅ Firebase
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // ✅ Local storage
    await LocalStorageService.instance.initializeFolders();

    // ✅ Notifications
    await NotificationService.instance.init(
      navigatorKey: navigatorKey,
      onTapAction: (screen) {
        // Friend's behavior: go home then switch tabs
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (r) => false);

        if (screen == 'journal') {
          bottomNavKey.currentState?.switchToTab(2);
        } else if (screen == 'home') {
          bottomNavKey.currentState?.switchToTab(0);
        } else if (screen != null && screen.startsWith('habit_')) {
          bottomNavKey.currentState?.switchToTab(1);
        }
      },
    );
  } catch (e) {
    debugPrint('Startup error: $e');
  }

  runApp(const RootApp());
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    final homeRepo = AbstractHomeRepo.getInstance();
    final activitiesRepo = AbstractActivitiesRepo.getInstance();
    final habitRepo = HabitRepository();
    final articlesRepo = ArticlesRepo();

    // This can be awaited in main, but keeping it here is okay if it's safe.
    habitRepo.rescheduleAllNotifications();

    return MultiBlocProvider(
      providers: [
        // ✅ MUST be global
        BlocProvider<AppLockCubit>(create: (_) => AppLockCubit()..loadLock()),

        BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()..checkAuthStatus()),

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
          supportedLocales: const [
            Locale('en'),
            Locale('fr'),
            Locale('ar'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // ✅ One global wrapper + one global auth redirect listener (prevents duplicated redirects)
          builder: (context, child) {
            return BlocListener<AuthCubit, app_auth.AuthState>(
              listenWhen: (prev, curr) =>
                  prev.isAuthenticated != curr.isAuthenticated,
              listener: (context, state) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final nav = navigatorKey.currentState;
                  if (nav == null) return;

                  if (!state.isAuthenticated) {
                    nav.pushNamedAndRemoveUntil('/login', (route) => false);
                  } else {
                    nav.pushNamedAndRemoveUntil('/home', (route) => false);
                  }
                });
              },
              child: PhoneLockWrapper(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },

          // ✅ Single entry point
          home: AppEntryPoint(lang: lang),

          routes: {
            '/login': (_) => const LoginScreen(),
            '/signup': (_) => const SignUpScreen(),
            '/home': (_) => BottomNavWrapper(key: bottomNavKey),
            '/profile': (_) => const ProfileScreen(),
            '/app-lock': (_) => const AppLockScreen(),
            '/language': (_) => const LanguageSelectionScreen(),
          },
        );
      },
    );
  }
}

class AppEntryPoint extends StatelessWidget {
  final String lang;
  const AppEntryPoint({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, app_auth.AuthState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const SplashScreen();
        }

        if (!state.isAuthenticated) {
          return const LoginScreen();
        }

        // Once authenticated:
        return FutureBuilder<bool>(
          future: WelcomeProvider.shouldShowWelcome(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SplashScreen();
            }

            // ✅ Load initial data once (safe here because we’re authenticated)
            if (state.user != null) {
              context.read<HomeCubit>().loadInitial(
                    userName: state.user!.fullName,
                    lang: lang,
                  );
            }

            if (snapshot.data == true) {
              return WelcomeScreen(
                onCompleted: () async {
                  await WelcomeProvider.markUserLoggedIn();
                  navigatorKey.currentState
                      ?.pushNamedAndRemoveUntil('/home', (r) => false);
                },
              );
            }

            return BottomNavWrapper(key: bottomNavKey);
          },
        );
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
