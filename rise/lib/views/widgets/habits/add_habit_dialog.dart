import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/style_simple/colors.dart';
import '../../../models/habit_model.dart';
import '../../widgets/error_dialog.dart';

class AddHabitDialog extends StatefulWidget {
  final List<Habit> existingHabits;

  const AddHabitDialog({super.key, required this.existingHabits});

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final TextEditingController _customNameCtrl = TextEditingController();
  String _frequency = 'Daily';
  String _habitType = 'good'; // 'good' or 'bad'
  TimeOfDay? _time;
  bool _reminder = false;

  late Map<String, String> _goodHabitOptions;
  late Map<String, String> _badHabitOptions;
  String _selectedHabitKey = Habit.keyDrinkWater;

  @override
  void initState() {
    super.initState();
  }

  void _initializeHabitOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    _goodHabitOptions = {
      Habit.keyDrinkWater: l10n.habitDrinkWater,
      Habit.keyExercise: l10n.habitExercise,
      Habit.keyMeditate: l10n.habitMeditate,
      Habit.keyRead: l10n.habitRead,
      Habit.keySleepEarly: l10n.habitSleepEarly,
      Habit.keyStudy: l10n.habitStudy,
      Habit.keyWalk: l10n.habitWalk,
      Habit.keyOther: l10n.habitOther,
    };
    
    _badHabitOptions = {
      Habit.keyNoSocialMedia: 'No Social Media Scrolling',
      Habit.keyNoSmoking: 'No Smoking',
      Habit.keyNoProcrastination: 'No Procrastination',
      Habit.keyOther: l10n.habitOther,
    };
  }

  // Get default points based on frequency and type
  int _getDefaultPoints() {
    switch (_frequency) {
      case 'Daily':
        return _habitType == 'bad' ? 15 : 10;
      case 'Weekly':
        return _habitType == 'bad' ? 75 : 50;
      case 'Monthly':
        return _habitType == 'bad' ? 300 : 200;
      default:
        return 10;
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AppErrorDialog(
        title: title,
        message: message,
      ),
    );
  }

  @override
  void dispose() {
    _customNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _initializeHabitOptions(context);
    
    bool isCustom = _selectedHabitKey == Habit.keyOther;
    final currentOptions = _habitType == 'good' ? _goodHabitOptions : _badHabitOptions;
    final defaultPoints = _getDefaultPoints();

    return AlertDialog(
      title: Text(l10n.addNewHabit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Habit Type Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Habit Type',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _habitType = 'good';
                                _selectedHabitKey = Habit.keyDrinkWater;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _habitType == 'good'
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _habitType == 'good'
                                      ? Colors.green
                                      : Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.add_circle,
                                    color: Colors.green,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'To Build',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: _habitType == 'good'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _habitType = 'bad';
                                _selectedHabitKey = Habit.keyNoSocialMedia;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _habitType == 'bad'
                                    ? Colors.red.withOpacity(0.3)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _habitType == 'bad'
                                      ? Colors.red
                                      : Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'To Stop',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: _habitType == 'bad'
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Habit Selection
            DropdownButtonFormField<String>(
              initialValue: currentOptions.containsKey(_selectedHabitKey) 
                  ? _selectedHabitKey 
                  : Habit.keyOther,
              items: currentOptions.entries.map((entry) {
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
              initialValue: _frequency,
              items: [
                DropdownMenuItem(value: 'Daily', child: Text(l10n.today)),
                DropdownMenuItem(value: 'Weekly', child: Text(l10n.weekly)),
                DropdownMenuItem(value: 'Monthly', child: Text(l10n.monthly)),
              ],
              onChanged: (v) {
                setState(() {
                  _frequency = v!;
                  // Reset time and reminder for non-daily habits
                  if (_frequency != 'Daily') {
                    _time = null;
                    _reminder = false;
                  }
                });
              },
              decoration: InputDecoration(labelText: l10n.frequency),
            ),
            const SizedBox(height: 12),

            // Reward points display (read-only)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '$defaultPoints Points',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _habitType == 'bad' 
                  ? 'Higher rewards for breaking bad habits!'
                  : 'Earn points on completion',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),

            // Time and reminder only for daily habits
            if (_frequency == 'Daily') ...[
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
            
            const SizedBox(height: 12),
            // Info about task-to-habit progression
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Complete 10 times in a row to turn this task into a habit! 🎯',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
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
              title = currentOptions[_selectedHabitKey]!;
            }

            // Check if habit with same key AND frequency exists
            bool alreadyExists = widget.existingHabits.any((habit) =>
                habit.habitKey == habitKey && habit.frequency == _frequency);

            if (alreadyExists) {
              _showErrorDialog(
                l10n.habitErrorAlreadyExists,
                l10n.habitAlreadyExists(_frequency),
              );
              return;
            }

            int points = _getDefaultPoints();
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
                habitType: _habitType,
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