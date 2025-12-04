import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/style_simple/colors.dart';
import '../../../models/habit_model.dart';

class AddHabitDialog extends StatefulWidget {
  final List<Habit> existingHabits;

  const AddHabitDialog({super.key, required this.existingHabits});

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final TextEditingController _customNameCtrl = TextEditingController();
  final TextEditingController _pointsCtrl = TextEditingController(text: '10');
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
  void initState() {
    super.initState();
    // Set default points based on frequency
    _updateDefaultPoints();
  }

  void _updateDefaultPoints() {
    switch (_frequency) {
      case 'Daily':
        _pointsCtrl.text = '10';
        break;
      case 'Weekly':
        _pointsCtrl.text = '50';
        break;
      case 'Monthly':
        _pointsCtrl.text = '200';
        break;
      case 'Yearly':
        _pointsCtrl.text = '1000';
        break;
    }
  }

  @override
  void dispose() {
    _customNameCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

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
                      Icon(_habitOptions[habit], color: AppColors.icon),
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
              onChanged: (v) {
                setState(() {
                  _frequency = v!;
                  _updateDefaultPoints();
                });
              },
              decoration: const InputDecoration(labelText: 'Frequency'),
            ),
            const SizedBox(height: 12),

            // Points Input Field - NEW
            TextField(
              controller: _pointsCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Reward Points',
                prefixIcon: const Icon(Icons.stars, color: Colors.amber),
                hintText: 'Points earned on completion',
                helperText: 'Customize the reward for this habit',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
                    style: const TextStyle(color: AppColors.icon),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              title: const Text('Set Reminder'),
              activeThumbColor: AppColors.icon,
              value: _reminder,
              onChanged: (v) => setState(() => _reminder = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.icon,
          ),
          onPressed: () {
            String title = isCustom
                ? (_customNameCtrl.text.trim().isEmpty
                    ? 'Custom Habit'
                    : _customNameCtrl.text.trim())
                : _selectedHabit;

            // Check for duplicates with same frequency
            bool alreadyExists = widget.existingHabits.any((habit) =>
                habit.title.toLowerCase() == title.toLowerCase() &&
                habit.frequency == _frequency);

            if (alreadyExists) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "This habit already exists with $_frequency frequency!",
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }

            // Validate points
            int points = int.tryParse(_pointsCtrl.text) ?? 10;
            if (points <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Points must be greater than 0!'),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }

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
                points: points, // Pass the custom points
              ),
            );
          },
          child: const Text(
            'Add',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
      backgroundColor: AppColors.card,
    );
  }
}
