import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_project/logic/applock/app_lock_cubit.dart';
import 'package:the_project/views/screens/auth/verify_lock_screen.dart';
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

class _PhoneLockWrapperState extends State<PhoneLockWrapper>
    with WidgetsBindingObserver {
  late AppLockCubit _appLockCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _appLockCubit = context.read<AppLockCubit>();

    // ✅ load once at startup
    _appLockCubit.loadLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused ||
      state == AppLifecycleState.inactive ||
      state == AppLifecycleState.detached) {

    _appLockCubit.setBypassLock(false);   // ✅ ADD THIS
    _appLockCubit.resetAuthentication();
  }

  if (state == AppLifecycleState.resumed) {
    _appLockCubit.loadLock();
  }
}


  @override
Widget build(BuildContext context) {
  return BlocBuilder<AppLockCubit, AppLockState>(
    builder: (context, lockState) {
      if (lockState.isLoading) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      // bypass (AppLock settings page)
      if (lockState.bypassLock) {
        return widget.child;
      }

      // no lock => allow
      if (lockState.lockType == null || lockState.lockValue == null) {
        return widget.child;
      }

      // authenticated => allow
      if (lockState.isAuthenticated) {
        return widget.child;
      }

      // ✅ IMPORTANT: Provide a Navigator for VerifyLockScreen
      return Navigator(
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => const VerifyLockScreen(),
        ),
      );
    },
  );
}



}
