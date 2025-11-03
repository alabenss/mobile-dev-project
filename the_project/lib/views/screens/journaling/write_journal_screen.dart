import 'package:flutter/material.dart';
import '../../widgets/app_background.dart';
import '../../widgets/journal/journal_entry_model.dart';

class WriteJournalScreen extends StatefulWidget {
  final String? initialDateLabel;
  final int? initialMonth;
  final int? initialYear;
  final JournalEntryModel? existingEntry;

  const WriteJournalScreen({
    this.initialDateLabel,
    this.initialMonth,
    this.initialYear,
    super.key,
  })  : existingEntry = null;

  const WriteJournalScreen.edit({required this.existingEntry, super.key})
      : initialDateLabel = null,
        initialMonth = null,
        initialYear = null;

  @override
  State<WriteJournalScreen> createState() => _WriteJournalScreenState();
}

class _WriteJournalScreenState extends State<WriteJournalScreen> {
  late String _dateLabel;
  late DateTime _selectedDate;
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _bodyCtrl = TextEditingController();

  final List<String> _moods = [
    'assets/images/good.png',
    'assets/images/happy.png',
    'assets/images/tired.png',
  ];
  String _selectedMood = 'assets/images/good.png';

  @override
  void initState() {
    super.initState();

    if (widget.existingEntry != null) {
      _dateLabel = widget.existingEntry!.dateLabel;
      _selectedDate = widget.existingEntry!.date;
      _titleCtrl.text = widget.existingEntry!.title;
      _bodyCtrl.text = widget.existingEntry!.fullText;
      _selectedMood = widget.existingEntry!.moodImage;
    } else {
      final now = DateTime.now();
      _selectedDate = widget.initialMonth != null && widget.initialYear != null
          ? DateTime(widget.initialYear!, widget.initialMonth!, now.day)
          : now;
      _dateLabel = widget.initialDateLabel ?? _formatDate(_selectedDate);
    }
  }

  String _formatDate(DateTime d) =>
      '${_weekdayName(d.weekday)}, ${_monthName(d.month)} ${d.day}';
  
  String _weekdayName(int w) => [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday',
        'Friday', 'Saturday', 'Sunday'
      ][w - 1];
  
  String _monthName(int m) => [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _save,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withOpacity(0.6),
                      child: Image.asset(_selectedMood, width: 26, height: 26),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dateLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _bodyCtrl,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'Write more here...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () => _onIconPressed('background'),
                      icon: Image.asset(
                          'assets/icons/background.png',
                            width: 24,  // adjust size if needed
                             height: 24,
                             ),
                    ),
                        
                    IconButton(
                      onPressed: () => _onIconPressed('image'),
                      icon: const Icon(Icons.photo),
                    ),
                        
                    IconButton(
                      onPressed: () => _onIconPressed('emoji'),
                      icon: const Icon(Icons.emoji_emotions_outlined),
                        
                    ),
                        
                    IconButton(
                      onPressed: () => _onIconPressed('fonts'),
                      icon: const Icon(Icons.text_fields),
                    ),
                     
                    
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onIconPressed(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Icon: $action clicked')),
    );
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title')),
      );
      return;
    }

    final entry = JournalEntryModel(
      dateLabel: _dateLabel,
      date: _selectedDate,
      moodImage: _selectedMood,
      title: title,
      fullText: body,
    );

    Navigator.of(context).pop(entry);
  }
}