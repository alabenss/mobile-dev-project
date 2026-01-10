import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/applock/app_lock_cubit.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../logic/auth/auth_state.dart' as app_auth;
import '../screens/auth/verify_lock_screen.dart';

class PhoneLockWrapper extends StatefulWidget {
  final Widget child;

  const PhoneLockWrapper({
    super.key,
    required this.child,
  });

  @override
  State<PhoneLockWrapper> createState() => _PhoneLockWrapperState();
}

class _PhoneLockWrapperState extends State<PhoneLockWrapper>
    with WidgetsBindingObserver {
  late AppLockCubit _appLockCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _appLockCubit = context.read<AppLockCubit>();

    // Load lock settings at startup
    // Note: This is already called in RootApp, but calling again is safe
    _appLockCubit.loadLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // When app goes to background, reset authentication
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _appLockCubit.setBypassLock(false);
      _appLockCubit.resetAuthentication();
    }

    // When app comes back to foreground, reload lock settings
    if (state == AppLifecycleState.resumed) {
      _appLockCubit.loadLock();
    }
  }

  @override
  Widget build(BuildContext context) {
    // First check if user is logged in
    return BlocBuilder<AuthCubit, app_auth.AuthState>(
      builder: (context, authState) {
        // Don't show lock screen if user is not authenticated
        if (!authState.isAuthenticated) {
          return widget.child;
        }

        // User is authenticated, check lock status
        return BlocBuilder<AppLockCubit, AppLockState>(
          builder: (context, lockState) {
            // Show loading only during initial load
            if (lockState.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Bypass lock (e.g., when in AppLock settings page)
            if (lockState.bypassLock) {
              return widget.child;
            }

            // No lock configured => allow access
            if (lockState.lockType == null || lockState.lockValue == null) {
              return widget.child;
            }

            // User authenticated with lock => allow access
            if (lockState.isAuthenticated) {
              return widget.child;
            }

            // Lock is enabled but user not authenticated => show verify screen
            // Use a Navigator to prevent navigation issues
            return Navigator(
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: _appLockCubit,
                  child: const VerifyLockScreen(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}