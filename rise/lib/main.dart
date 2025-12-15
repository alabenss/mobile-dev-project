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
import 'database/db_helper.dart';

import 'views/widgets/common/bottom_nav_wrapper.dart';
import 'views/wrappers/phone_lock_wrapper.dart';
import 'views/screens/settings/profile.dart';
import 'views/screens/settings/app_lock_screen.dart';
import 'views/screens/settings/language_selection_screen.dart';
import 'views/screens/auth/login_screen.dart';
import 'views/screens/auth/signup_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();



  const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);

await localNotifications.initialize(initSettings,
    onDidReceiveNotificationResponse: (response) {
  // Handle tap when app is open
});



  FirebaseMessaging messaging = FirebaseMessaging.instance;

await messaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
);

String? token = await messaging.getToken();
print('FCM TOKEN: $token');

// Subscribe to topic (easy demo)
await messaging.subscribeToTopic('demo');



FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Notification received in foreground');

  final notification = message.notification;
  if (notification == null) return;

  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    'demo_channel',
    'Demo Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails details =
      NotificationDetails(android: androidDetails);

  localNotifications.show(
    0,
    notification.title,
    notification.body,
    details,
    payload: message.data['screen'],
  );
});



FirebaseMessaging.onMessageOpenedApp.listen((message) {
  handleNotificationNavigation(message);
});







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
          BlocProvider<LocaleCubit>(
            create: (_) => LocaleCubit(),
          ),
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

    // Show error screen
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
                      // Try to clear and reinitialize
                      try {
                        await DBHelper.clearAll();
                        await DBHelper.initializeDemoData();
                      } catch (_) {}
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, localeState) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,

          // Use locale from LocaleCubit, null means use system default
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

                // When authenticated, wrap main app with PhoneLockWrapper
                return const PhoneLockWrapper(
                  child: BottomNavWrapper(),
                );
              },
            ),
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/home': (context) => const BottomNavWrapper(),
            '/profile': (context) => const ProfileScreen(),
            '/app-lock': (context) => const AppLockScreen(),
            '/language': (context) => const LanguageSelectionScreen(),
          },
        );
      },
    );
  }
}



void handleNotificationNavigation(RemoteMessage message) {
  final screen = message.data['screen'];

  if (screen == 'home') {
    navigatorKey.currentState?.pushNamed('/home');
  } else if (screen == 'profile') {
    navigatorKey.currentState?.pushNamed('/profile');
  }
}
