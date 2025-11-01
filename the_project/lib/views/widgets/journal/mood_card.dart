import 'package:flutter/material.dart';

class MoodCard extends StatefulWidget {
  final String? selectedMood;
  final String? selectedMoodLabel;
  final DateTime? selectedTime;
  final Function(String moodImage, String moodLabel)? onMoodSelected;

  const MoodCard({
    super.key,
    this.selectedMood,
    this.selectedMoodLabel,
    this.selectedTime,
    this.onMoodSelected,
  });

  @override
  State<MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<MoodCard> {
  // 10 moods avec leurs images et labels
  final List<Map<String, String>> _moods = [
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
    final hasSelectedMood = widget.selectedMood != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: hasSelectedMood ? _buildSelectedMood() : _buildMoodSelector(),
    );
  }

  Widget _buildSelectedMood() {
    final time = widget.selectedTime ?? DateTime.now();
    final formattedTime = _formatDateTime(time);

    return Row(
      children: [
        Image.asset(widget.selectedMood!, height: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.selectedMoodLabel ?? 'Good',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formattedTime,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.grey),
          onPressed: () {
            // Allow user to change mood
            widget.onMoodSelected?.call('', ''); // Reset to show selector
          },
        ),
      ],
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How do you feel today?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _moods.length,
            itemBuilder: (context, index) {
              final mood = _moods[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () {
                    widget.onMoodSelected?.call(
                      mood['image']!,
                      mood['label']!,
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          mood['image']!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood['label']!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final day = date.day;
    final month = _getMonthName(date.month);
    
    return 'Today, $month $day, $hour:$minute $period';
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}