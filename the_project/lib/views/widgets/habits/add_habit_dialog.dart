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

  late Map<String, String> _habitOptions; // key -> localized name
  String _selectedHabitKey = Habit.keyDrinkWater;

  @override
  void initState() {
    super.initState();
    _updateDefaultPoints();
  }

  void _initializeHabitOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _habitOptions = {
      Habit.keyDrinkWater: l10n.habitDrinkWater,
      Habit.keyExercise: l10n.habitExercise,
      Habit.keyMeditate: l10n.habitMeditate,
      Habit.keyRead: l10n.habitRead,
      Habit.keySleepEarly: l10n.habitSleepEarly,
      Habit.keyStudy: l10n.habitStudy,
      Habit.keyWalk: l10n.habitWalk,
      Habit.keyOther: l10n.habitOther,
    };
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
    
    bool isCustom = _selectedHabitKey == Habit.keyOther;

    return AlertDialog(
      title: Text(l10n.addNewHabit),
      content: SingleChildScrollView(
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedHabitKey,
              items: _habitOptions.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(Habit.getIconForKey(entry.key), color: AppColors.icon),
                      const SizedBox(width: 10),
                      Text(entry.value),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedHabitKey = v!),
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
            String habitKey;
            String title;
            
            if (isCustom) {
              final customName = _customNameCtrl.text.trim();
              if (customName.isEmpty) {
                title = l10n.customHabit;
                habitKey = 'custom_${DateTime.now().millisecondsSinceEpoch}';
              } else {
                title = customName;
                habitKey = customName.toLowerCase().replaceAll(' ', '_');
              }
            } else {
              habitKey = _selectedHabitKey;
              title = _habitOptions[_selectedHabitKey]!;
            }

            // Check for duplicates using habitKey and frequency
            bool alreadyExists = widget.existingHabits.any((habit) =>
                habit.habitKey == habitKey && habit.frequency == _frequency);

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

            IconData icon = Habit.getIconForKey(habitKey);

            Navigator.pop(
              context,
              Habit(
                title: title,
                habitKey: habitKey,
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