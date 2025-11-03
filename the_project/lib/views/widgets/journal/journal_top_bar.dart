import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';

class JournalTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onSave;
  final String selectedMood;

  const JournalTopBar({
    super.key,
    required this.onBack,
    required this.onSave,
    required this.selectedMood,
  });

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.accentBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: AppColors.card),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.card.withOpacity(0.0),
            child: Image.asset(selectedMood, width: 35, height: 35),
          ),
        ],
      ),
    );
  }
}
