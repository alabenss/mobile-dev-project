import 'package:flutter/material.dart';
import 'dart:async';
import '../../themes/style_simple/colors.dart';

class PhoneLockOverlay extends StatefulWidget {
  final DateTime lockEndTime;
  final VoidCallback onDisable;

  const PhoneLockOverlay({
    super.key,
    required this.lockEndTime,
    required this.onDisable,
  });

  @override
  State<PhoneLockOverlay> createState() => _PhoneLockOverlayState();
}

class _PhoneLockOverlayState extends State<PhoneLockOverlay> {
  Timer? _timer;
  String _remainingTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    final difference = widget.lockEndTime.difference(now);

    if (difference.isNegative) {
      setState(() {
        _remainingTime = '0:00';
      });
    } else {
      final minutes = difference.inMinutes;
      final seconds = difference.inSeconds % 60;
      setState(() {
        _remainingTime = '$minutes:${seconds.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Prevent back button
      child: Material(
        color: AppColors.backgroundColor.withOpacity(0.98),
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lock icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentBlue.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_clock,
                    size: 60,
                    color: AppColors.accentBlue,
                  ),
                ),
                const SizedBox(height: 40),

                // Timer
                Text(
                  _remainingTime,
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),

                // Message
                const Text(
                  'Phone is locked',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Take a break from your screen.\nYour digital detox is in progress.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 60),

                // Progress indicator
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accentGreen.withOpacity(0.3),
                      width: 8,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.self_improvement,
                          size: 64,
                          color: AppColors.accentGreen,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Stay strong!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentGreen.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),

                // Disable button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.card,
                          title: const Text(
                            'Disable Lock?',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                          content: const Text(
                            'If you disable the lock early, your detox progress will not increase. Are you sure?',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Stay Locked',
                                style: TextStyle(color: AppColors.accentGreen),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onDisable();
                              },
                              child: const Text(
                                'Disable',
                                style: TextStyle(color: AppColors.accentBlue),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accentBlue, width: 2),
                      foregroundColor: AppColors.accentBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Disable Lock',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}