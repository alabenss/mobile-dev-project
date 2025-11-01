import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';
import 'habit_model.dart';

class AddHabitDialog extends StatefulWidget {
  const AddHabitDialog({super.key});

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final TextEditingController _customNameCtrl = TextEditingController();
  String _frequency = 'Daily';
  TimeOfDay? _time;
  bool _reminder = false;

  final Map<String, IconData> _habitOptions = {
    'Drink Water': Icons.local_drink,
    'Exercise': Icons.fitness_center,
    'Meditate': Icons.self_improvement,
    'Read': Icons.book,
    'Sleep Early': Icons.bedtime,
    'Study': Icons.school,
    'Walk': Icons.directions_walk,
    'Other': Icons.star_border,
  };

  String _selectedHabit = 'Drink Water';

  @override
  Widget build(BuildContext context) {
    bool isCustom = _selectedHabit == 'Other';

    return AlertDialog(
      title: const Text('Add New Habit'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedHabit,
              items: _habitOptions.keys.map((habit) {
                return DropdownMenuItem(
                  value: habit,
                  child: Row(
                    children: [
                      Icon(_habitOptions[habit], color: AppColors.accentPink),
                      const SizedBox(width: 10),
                      Text(habit),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedHabit = v!),
              decoration: const InputDecoration(labelText: 'Select Habit'),
            ),
            if (isCustom)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: _customNameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Custom Habit Name'),
                ),
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _frequency,
              items: const [
                DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'Yearly', child: Text('Yearly')),
              ],
              onChanged: (v) => setState(() => _frequency = v!),
              decoration: const InputDecoration(labelText: 'Frequency'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Time:'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) setState(() => _time = picked);
                  },
                  child: Text(
                    _time != null ? _time!.format(context) : 'Select time',
                    style: const TextStyle(color: AppColors.accentPink),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text('Set Reminder'),
              activeThumbColor: AppColors.accentPink,
              value: _reminder,
              onChanged: (v) => setState(() => _reminder = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentPink,
          ),
          onPressed: () {
            String title = isCustom
                ? (_customNameCtrl.text.trim().isEmpty
                    ? 'Custom Habit'
                    : _customNameCtrl.text.trim())
                : _selectedHabit;

            IconData icon = isCustom
                ? Icons.star_border
                : _habitOptions[_selectedHabit]!;

            Navigator.pop(
              context,
              Habit(
                title: title,
                icon: icon,
                frequency: _frequency,
                time: _time,
                reminder: _reminder,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
