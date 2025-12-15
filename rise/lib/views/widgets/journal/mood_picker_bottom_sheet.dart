import 'package:flutter/material.dart';
import 'package:the_project/l10n/app_localizations.dart';
import '../../themes/style_simple/colors.dart';

class MoodPickerBottomSheet extends StatelessWidget {
  final String currentMood;
  final Function(String moodImage, String moodLabel) onMoodSelected;

  const MoodPickerBottomSheet({
    super.key,
    required this.currentMood,
    required this.onMoodSelected,
  });

  List<Map<String, String>> _getMoods(AppLocalizations l10n) => [
        {'image': 'assets/images/happy.png', 'label': l10n.journalMoodHappy},
        {'image': 'assets/images/good.png', 'label': l10n.journalMoodGood},
        {'image': 'assets/images/excited.png', 'label': l10n.journalMoodExcited},
        {'image': 'assets/images/calm.png', 'label': l10n.journalMoodCalm},
        {'image': 'assets/images/sad.png', 'label': l10n.journalMoodSad},
        {'image': 'assets/images/tired.png', 'label': l10n.journalMoodTired},
        {'image': 'assets/images/anxious.png', 'label': l10n.journalMoodAnxious},
        {'image': 'assets/images/angry.png', 'label': l10n.journalMoodAngry},
        {'image': 'assets/images/confused.png', 'label': l10n.journalMoodConfused},
        {'image': 'assets/images/grateful.png', 'label': l10n.journalMoodGrateful},
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final moods = _getMoods(l10n);

    return Container(
      height: 380,
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.journalMoodTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ADDED SingleChildScrollView as parent to handle horizontal overflow
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: moods.map((mood) {
                        final isSelected = currentMood == mood['image'];

                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              onMoodSelected(mood['image']!, mood['label']!);
                              Navigator.pop(context);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.accentBlue.withOpacity(0.2)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: AppColors.accentBlue,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Image.asset(
                                    mood['image']!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // FIXED: Proper width constraint and text alignment
                                SizedBox(
                                  width: 70, // Fixed width
                                  child: Text(
                                    mood['label']!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected
                                          ? AppColors.accentBlue
                                          : AppColors.textSecondary,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

