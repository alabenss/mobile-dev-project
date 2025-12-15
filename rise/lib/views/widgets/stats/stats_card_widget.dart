import 'package:flutter/material.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';

class StatsCardWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const StatsCardWidget({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.card.withOpacity(0.98),
            AppColors.card.withOpacity(0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(12),
      child: child,
    );
  }
}