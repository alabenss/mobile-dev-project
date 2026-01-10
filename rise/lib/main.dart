import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:the_project/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'services/notification_service.dart';
import '/services/local_storage_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Supabase first
  try {
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
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Supabase initialization failed: $e');
  }

  // ✅ Firebase
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
    final articlesRepo = ArticlesRepo();

    await habitRepo.rescheduleAllNotifications();
    print('Habit notifications rescheduled');

    runApp(
      MultiBlocProvider(
        providers: [
          // ✅ AppLockCubit's provider must be GLOBAL
          BlocProvider<AppLockCubit>(
            create: (_) => AppLockCubit()..loadLock(),
          ),

          BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),

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

  // ✅ GLOBAL auth redirect (THIS IS THE FIX)
  builder: (context, child) {
    return BlocListener<AuthCubit, app_auth.AuthState>(
      listenWhen: (prev, curr) =>
          prev.isAuthenticated != curr.isAuthenticated,
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final nav = navigatorKey.currentState;
          if (nav == null) return;

          // 🔒 Logged out → ALWAYS go to login
          if (!state.isAuthenticated) {
            nav.pushNamedAndRemoveUntil('/login', (route) => false);
          }

          // 🔓 Logged in → go to home
          if (state.isAuthenticated) {
            nav.pushNamedAndRemoveUntil('/home', (route) => false);
          }
        });
      },
      child: PhoneLockWrapper(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  },


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
              if (welcomeSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (welcomeSnapshot.hasData && welcomeSnapshot.data == true) {
                return WelcomeScreen(
                  onCompleted: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const AppEntryPoint(),
                      ),
                    );
                  },
                );
              }

              return const AppEntryPoint();
            },
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),

            // ✅ NO wrapper here anymore
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

class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, app_auth.AuthState>(
      listener: (context, state) {
        final lang = 'en';

        if (state.isAuthenticated && state.user != null) {
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

          // ✅ NO wrapper here anymore
          return BottomNavWrapper(key: bottomNavKey);
        },
      ),
    );
  }
}
