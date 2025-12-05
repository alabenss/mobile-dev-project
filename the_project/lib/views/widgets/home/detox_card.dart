import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';
import '../../themes/style_simple/styles.dart';

class DetoxCard extends StatelessWidget {
  final double progress;
  final VoidCallback onLockPhone;
  final VoidCallback onReset;
  final bool isLocked;
  final DateTime? lockEndTime;
  final VoidCallback onDisableLock;
  final bool permissionDenied;
  final VoidCallback? onPermissionDeniedDismiss;
  
  const DetoxCard({
    super.key,
    required this.progress,
    required this.onLockPhone,
    required this.onReset,
    this.isLocked = false,
    this.lockEndTime,
    required this.onDisableLock,
    this.permissionDenied = false,
    this.onPermissionDeniedDismiss,
  });

  String _getRemainingTime() {
    if (lockEndTime == null) return '0:00';
    
    final now = DateTime.now();
    final difference = lockEndTime!.difference(now);
    
    if (difference.isNegative) return '0:00';
    
    final minutes = difference.inMinutes;
    final seconds = difference.inSeconds % 60;
    
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double p = progress.clamp(0, 1);
    final bool isComplete = p >= 1.0;

    // If phone is locked, show timer interface
    if (isLocked) {
      return Card(
        color: AppColors.card,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 150),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Digital detox:', style: AppText.sectionTitle),
                const SizedBox(height: 6),
                Image.asset('assets/images/phone_lock.png', width: 28, height: 28),
                const SizedBox(height: 12),
                const Center(
                  child: Icon(
                    Icons.lock_clock,
                    size: 32,
                    color: AppColors.accentBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _getRemainingTime(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Phone is locked',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: OutlinedButton(
                    onPressed: onDisableLock,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.accentBlue, width: 1.2),
                      foregroundColor: AppColors.accentBlue,
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Disable Lock'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Normal detox card interface
    return Card(
      color: AppColors.card,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 150),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Digital detox:', style: AppText.sectionTitle),
              const SizedBox(height: 6),
              Image.asset('assets/images/phone_lock.png', width: 28, height: 28),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(text: '${(p * 100).round()}%', style: AppText.chipBold),
                          const TextSpan(
                            text: '  complete',
                            style: TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isComplete)
                    SizedBox(
                      height: 30,
                      child: OutlinedButton(
                        onPressed: onReset,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.accentBlue, width: 1.2),
                          foregroundColor: AppColors.accentBlue,
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: const Size(58, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Reset'),
                      ),
                    )
                  else
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: onLockPhone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          minimumSize: const Size(58, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Lock 30m'),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: p,
                  minHeight: 6,
                  color: AppColors.accentGreen,
                  backgroundColor: AppColors.backgroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}