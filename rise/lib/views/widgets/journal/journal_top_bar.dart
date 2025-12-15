import 'package:flutter/material.dart';
import 'package:the_project/l10n/app_localizations.dart';
import '../../themes/style_simple/colors.dart';

class JournalTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSave;
  final String selectedMood;
  final VoidCallback onMoodTap;

  const JournalTopBar({
    super.key,
    required this.onBack,
    required this.onSave,
    required this.selectedMood,
    required this.onMoodTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      color: AppColors.card.withOpacity(0.0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const Spacer(),
          TextButton(
            onPressed: onSave,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.icon,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.journalSave,
                style: const TextStyle(color: AppColors.card),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onMoodTap,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.card.withOpacity(0.0),
                child: Image.asset(selectedMood, width: 35, height: 35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}