import 'package:flutter/material.dart';
import '../../widgets/app_background.dart';
import '../../widgets/journal/journal_entry_model.dart';
import '../../widgets/journal/mood_card.dart';
import '../../widgets/journal/month_year_selector.dart';
import '../../widgets/journal/calendar_row.dart';
import '../../widgets/journal/journal_entry_template.dart';
import 'write_journal_screen.dart';

class JournalingScreen extends StatefulWidget {
  const JournalingScreen({Key? key}) : super(key: key);

  @override
  State<JournalingScreen> createState() => _JournalingScreenState();
}

class _JournalingScreenState extends State<JournalingScreen> {
  late List<JournalEntryModel> _allEntries;
  List<JournalEntryModel> _filteredEntries = [];
  
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  String? _selectedDateLabel;
  
  // Variables pour le MoodCard
  String? _todayMood;
  String? _todayMoodLabel;
  DateTime? _todayMoodTime;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _allEntries = [
      // October 15, 2025 - 2 journals
      JournalEntryModel(
        dateLabel: 'Wednesday, Oct 15',
        date: DateTime(2025, 10, 15, 9, 30),
        moodImage: "assets/images/good.png",
        title: "Morning Reflection",
        fullText: "Started the day with meditation. Feeling calm and focused.",
      ),
      JournalEntryModel(
        dateLabel: 'Wednesday, Oct 15',
        date: DateTime(2025, 10, 15, 18, 45),
        moodImage: "assets/images/happy.png",
        title: "Evening Gratitude",
        fullText: "Grateful for a productive day. Met all my goals!",
      ),
      
      // October 22, 2025 - 1 journal
      JournalEntryModel(
        dateLabel: 'Wednesday, Oct 22',
        date: DateTime(2025, 10, 22, 14, 0),
        moodImage: "assets/images/tired.png",
        title: "Midday Break",
        fullText: "Feeling a bit tired but pushing through. Coffee helps!",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openWritePage(),
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MoodCard(
                selectedMood: _todayMood,
                selectedMoodLabel: _todayMoodLabel,
                selectedTime: _todayMoodTime,
                onMoodSelected: (moodImage, moodLabel) {
                  setState(() {
                    if (moodImage.isEmpty) {
                      // Reset to show selector
                      _todayMood = null;
                      _todayMoodLabel = null;
                      _todayMoodTime = null;
                    } else {
                      _todayMood = moodImage;
                      _todayMoodLabel = moodLabel;
                      _todayMoodTime = DateTime.now();
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              
              MonthYearSelector(
                selectedMonth: _selectedMonth,
                selectedYear: _selectedYear,
                onChanged: (month, year) {
                  setState(() {
                    _selectedMonth = month;
                    _selectedYear = year;
                    _selectedDateLabel = null;
                    _filteredEntries = [];
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              CalendarRow(
                month: _selectedMonth,
                year: _selectedYear,
                selectedDateLabel: _selectedDateLabel,
                entriesByDate: _getEntriesByDate(),
                onDateTap: (dateLabel) {
                  setState(() {
                    _selectedDateLabel = dateLabel;
                    _filteredEntries = _allEntries
                        .where((e) => e.dateLabel == dateLabel)
                        .toList();
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              Expanded(
                child: _selectedDateLabel == null
                    ? Center(
                        child: Text(
                          'Select a day to view journals',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      )
                    : _filteredEntries.isEmpty
                        ? Center(
                            child: Text(
                              'No journals for this day',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredEntries.length,
                            itemBuilder: (context, index) {
                              final entry = _filteredEntries[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: JournalEntryTemplate(
                                  title: entry.title,
                                  time: _formatTime(entry.date),
                                  moodImage: entry.moodImage,
                                  onTap: () => _openEditPage(entry),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, int> _getEntriesByDate() {
    final Map<String, int> entriesByDate = {};
    for (var entry in _allEntries) {
      if (entry.date.month == _selectedMonth && 
          entry.date.year == _selectedYear) {
        entriesByDate[entry.dateLabel] = 
            (entriesByDate[entry.dateLabel] ?? 0) + 1;
      }
    }
    return entriesByDate;
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Future<void> _openWritePage({String? initialDateLabel}) async {
    // Verify the date is not in the future
    if (initialDateLabel != null) {
      final selectedDate = _parseDateLabel(initialDateLabel);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      if (selectedDate.isAfter(today)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot create journal for future dates'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final result = await Navigator.of(context).push<JournalEntryModel>(
      MaterialPageRoute(
        builder: (_) => WriteJournalScreen(
          initialDateLabel: initialDateLabel ?? _selectedDateLabel,
          initialMonth: _selectedMonth,
          initialYear: _selectedYear,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _allEntries.add(result);
        if (_selectedDateLabel == result.dateLabel) {
          _filteredEntries.add(result);
        }
      });
    }
  }

  DateTime _parseDateLabel(String label) {
    // Parse "Wednesday, Oct 15" back to DateTime
    final parts = label.split(', ');
    if (parts.length != 2) return DateTime.now();
    
    final dateParts = parts[1].split(' ');
    if (dateParts.length != 2) return DateTime.now();
    
    final monthStr = dateParts[0];
    final day = int.tryParse(dateParts[1]) ?? 1;
    
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months.indexOf(monthStr) + 1;
    
    return DateTime(_selectedYear, month, day);
  }

  Future<void> _openEditPage(JournalEntryModel entry) async {
    final result = await Navigator.of(context).push<JournalEntryModel>(
      MaterialPageRoute(
        builder: (_) => WriteJournalScreen.edit(existingEntry: entry),
      ),
    );

    if (result != null) {
      setState(() {
        final index = _allEntries.indexWhere((e) => 
          e.date == entry.date && e.dateLabel == entry.dateLabel);
        if (index != -1) {
          _allEntries[index] = result;
          if (_selectedDateLabel == result.dateLabel) {
            final filteredIndex = _filteredEntries.indexWhere((e) =>
              e.date == entry.date && e.dateLabel == entry.dateLabel);
            if (filteredIndex != -1) {
              _filteredEntries[filteredIndex] = result;
            }
          }
        }
      });
    }
  }
}



