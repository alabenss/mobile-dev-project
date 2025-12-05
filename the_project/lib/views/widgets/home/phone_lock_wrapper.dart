import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/home/home_cubit.dart';
import '../../../logic/home/home_state.dart';
import 'phone_lock_overlay.dart';

/// Wrapper widget that shows the lock overlay when phone is locked
/// Place this at the root of your navigation or around your main content
class PhoneLockWrapper extends StatelessWidget {
  final Widget child;

  const PhoneLockWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        // If phone is locked, show full-screen overlay
        if (state.isPhoneLocked && state.lockEndTime != null) {
          final now = DateTime.now();
          
          // Check if lock time has expired
          if (now.isAfter(state.lockEndTime!)) {
            // Lock expired, this will be handled by the cubit's timer
            return child;
          }
          
          return PhoneLockOverlay(
            lockEndTime: state.lockEndTime!,
            onDisable: () {
              context.read<HomeCubit>().disableLock();
            },
          );
        }
        
        // Normal app content
        return child;
      },
    );
  }
}