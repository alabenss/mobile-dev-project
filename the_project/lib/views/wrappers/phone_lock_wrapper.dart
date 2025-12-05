
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_project/logic/applock/app_lock_cubit.dart';
import 'package:the_project/views/screens/auth/verify_lock_screen.dart';

class PhoneLockWrapper extends StatefulWidget {
  final Widget child;

  const PhoneLockWrapper({
    super.key,
    required this.child,
  });

  @override
  State<PhoneLockWrapper> createState() => _PhoneLockWrapperState();
}

class _PhoneLockWrapperState extends State<PhoneLockWrapper> {
  late AppLockCubit _appLockCubit;

  @override
  void initState() {
    super.initState();
    _appLockCubit = AppLockCubit();
    _appLockCubit.loadLock();
  }

  @override
  void dispose() {
    _appLockCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _appLockCubit,
      child: BlocBuilder<AppLockCubit, AppLockState>(
        builder: (context, lockState) {
          print('AppLock State: isLoading=${lockState.isLoading}, lockType=${lockState.lockType}, isAuthenticated=${lockState.isAuthenticated}');
          
          // Show loading while checking lock status
          if (lockState.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // If no lock is set, show the app directly
          if (lockState.lockType == null || lockState.lockValue == null) {
            print('No app lock set, showing app directly');
            return widget.child;
          }

          // If lock is set but user is authenticated, show the app
          if (lockState.isAuthenticated) {
            print('App lock set and user authenticated, showing app');
            return widget.child;
          }

          // If lock is set but not authenticated, show verification screen
          print('App lock set but user not authenticated, showing verify screen');
          return VerifyLockScreen();
        },
      ),
    );
  }
}
