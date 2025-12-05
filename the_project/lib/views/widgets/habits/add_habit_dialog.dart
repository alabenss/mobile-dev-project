import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
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

  late Map<String, IconData> _habitOptions;

  String _selectedHabit = 'Drink Water';

  @override
  void initState() {
    super.initState();
    // Set default points based on frequency
    _updateDefaultPoints();
  }

  void _initializeHabitOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _habitOptions = {
      l10n.habitDrinkWater: Icons.local_drink,
      l10n.habitExercise: Icons.fitness_center,
      l10n.habitMeditate: Icons.self_improvement,
      l10n.habitRead: Icons.book,
      l10n.habitSleepEarly: Icons.bedtime,
      l10n.habitStudy: Icons.school,
      l10n.habitWalk: Icons.directions_walk,
      l10n.habitOther: Icons.star_border,
    };
    
    // Set default selected habit to first option
    if (_selectedHabit == 'Drink Water') {
      _selectedHabit = l10n.habitDrinkWater;
    }
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
    final l10n = AppLocalizations.of(context)!;
    _initializeHabitOptions(context);
    
    bool isCustom = _selectedHabit == l10n.habitOther;

    return AlertDialog(
      title: Text(l10n.addNewHabit),
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
              decoration: InputDecoration(labelText: l10n.selectHabit),
            ),
            if (isCustom)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: _customNameCtrl,
                  decoration: InputDecoration(labelText: l10n.customHabitName),
                ),
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _frequency,
              items: [
                DropdownMenuItem(value: 'Daily', child: Text(l10n.today)),
                DropdownMenuItem(value: 'Weekly', child: Text(l10n.weekly)),
                DropdownMenuItem(value: 'Monthly', child: Text(l10n.monthly)),
              ],
              onChanged: (v) {
                setState(() {
                  _frequency = v!;
                  _updateDefaultPoints();
                });
              },
              decoration: InputDecoration(labelText: l10n.frequency),
            ),
            const SizedBox(height: 12),

            // Points Input Field
            TextField(
              controller: _pointsCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.rewardPoints,
                prefixIcon: const Icon(Icons.stars, color: Colors.amber),
                hintText: l10n.pointsEarnedOnCompletion,
                helperText: l10n.customizeReward,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Text(l10n.time),
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
                    _time != null ? _time!.format(context) : l10n.selectTime,
                    style: const TextStyle(color: AppColors.icon),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              title: Text(l10n.setReminder),
              activeThumbColor: AppColors.icon,
              value: _reminder,
              onChanged: (v) => setState(() => _reminder = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            l10n.cancel,
            style: const TextStyle(color: AppColors.textPrimary),
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
                    ? l10n.customHabit
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
                    l10n.habitAlreadyExists(_frequency),
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
                SnackBar(
                  content: Text(l10n.pointsMustBeGreaterThanZero),
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
                points: points,
              ),
            );
          },
          child: Text(
            l10n.add,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
      backgroundColor: AppColors.card,
    );
  }
}