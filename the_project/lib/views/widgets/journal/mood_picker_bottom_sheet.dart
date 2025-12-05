import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';

class MoodPickerBottomSheet extends StatelessWidget {
  final String currentMood;
  final Function(String moodImage, String moodLabel) onMoodSelected;

  const MoodPickerBottomSheet({
    super.key,
    required this.currentMood,
    required this.onMoodSelected,
  });

  static const List<Map<String, String>> _moods = [
    {'image': 'assets/images/happy.png', 'label': 'Happy'},
    {'image': 'assets/images/good.png', 'label': 'Good'},
    {'image': 'assets/images/excited.png', 'label': 'Excited'},
    {'image': 'assets/images/calm.png', 'label': 'Calm'},
    {'image': 'assets/images/sad.png', 'label': 'Sad'},
    {'image': 'assets/images/tired.png', 'label': 'Tired'},
    {'image': 'assets/images/anxious.png', 'label': 'Anxious'},
    {'image': 'assets/images/angry.png', 'label': 'Angry'},
    {'image': 'assets/images/confused.png', 'label': 'Confused'},
    {'image': 'assets/images/grateful.png', 'label': 'Grateful'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'How do you feel?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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

          // Mood Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: _moods.length,
              itemBuilder: (context, index) {
                final mood = _moods[index];
                final isSelected = currentMood == mood['image'];

                return GestureDetector(
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
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood['label']!,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? AppColors.accentBlue
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}