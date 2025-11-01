// lib/views/screens/homescreen/journaling_screen.dart

import 'package:flutter/material.dart';
import '../../widgets/app_background.dart';

class JournalingScreen extends StatefulWidget {
  const JournalingScreen({Key? key}) : super(key: key);

  @override
  State<JournalingScreen> createState() => _JournalingScreenState();
}

class _JournalingScreenState extends State<JournalingScreen> {
  DateTime selectedDate = DateTime.now();

  // In-memory list of journal entries (prototype)
  final List<JournalEntryModel> _entries = [
    JournalEntryModel(
      dateLabel: "Monday, Nov 6",
      moodImage: "assets/images/sunrise.png",
      textPreview: "Had a productive and calm day.",
    ),
    JournalEntryModel(
      dateLabel: "Tuesday, Nov 7",
      moodImage: "assets/images/happy.png",
      textPreview: "Felt energetic and focused.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Open the "Add New Journal" prototype page and wait for result
          final result = await Navigator.of(context).push<JournalEntryModel>(
            MaterialPageRoute(
              builder: (_) => const WriteJournalPage(),
            ),
          );

          if (result != null) {
            setState(() {
              // Add the created entry at the top as in the requested example
              _entries.insert(
                  0,
                  JournalEntryModel(
                    dateLabel: result.dateLabel,
                    moodImage: result.moodImage,
                    textPreview: result.textPreview,
                  ));
            });
          }
        },
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Mood Card
                const MoodCard(),

                const SizedBox(height: 20),

                // Calendar Row
                CalendarRow(onDateTap: (label) {
                  // For prototype: if an entry exists with that label, navigate to detail
                  final found = _entries.firstWhere(
                      (e) => e.dateLabel == label,
                      orElse: () => JournalEntryModel.empty());

                  if (!found.isEmpty) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => JournalDetailPage(entry: found)));
                  } else {
                    // open writer prefilled with that date label
                    Navigator.of(context)
                        .push<JournalEntryModel>(
                      MaterialPageRoute(
                        builder: (_) => WriteJournalPage(initialDateLabel: label),
                      ),
                    )
                        .then((res) {
                      if (res != null) {
                        setState(() => _entries.insert(0, res));
                      }
                    });
                  }
                }),

                const SizedBox(height: 20),

                // Journal Entries Template (from state)
                ..._entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: JournalEntryTemplate(
                            date: e.dateLabel,
                            moodImage: e.moodImage,
                            textPreview: e.textPreview,
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => JournalDetailPage(entry: e))),
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------- Models ---------------------------------------
class JournalEntryModel {
  final String dateLabel;
  final String moodImage;
  final String textPreview;
  final bool isEmpty;

  JournalEntryModel({
    required this.dateLabel,
    required this.moodImage,
    required this.textPreview,
  }) : isEmpty = false;

  JournalEntryModel.empty()
      : dateLabel = '',
        moodImage = '',
        textPreview = '',
        isEmpty = true;
}

// --------------------------- Widgets --------------------------------------
class MoodCard extends StatelessWidget {
  const MoodCard({super.key});

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          Image.asset(
            'assets/images/sunrise.png',
            height: 40,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Good',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Today, November 6, 11:00 PM',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CalendarRow extends StatelessWidget {
  final void Function(String dateLabel)? onDateTap;
  const CalendarRow({super.key, this.onDateTap});

  @override
  Widget build(BuildContext context) {
    final days = [
      {"day": "Mon", "date": "6", "label": "Monday, Nov 6"},
      {"day": "Tue", "date": "7", "label": "Tuesday, Nov 7"},
      {"day": "Wed", "date": "8", "label": "Wednesday, Nov 8"},
      {"day": "Thu", "date": "9", "label": "Thursday, Nov 9"},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((d) {
        return GestureDetector(
          onTap: () => onDateTap?.call(d['label']!),
          child: Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  d["day"]!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  d["date"]!,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class JournalEntryTemplate extends StatelessWidget {
  final String date;
  final String moodImage;
  final String textPreview;
  final VoidCallback? onTap;

  const JournalEntryTemplate({
    Key? key,
    required this.date,
    required this.moodImage,
    required this.textPreview,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              moodImage,
              height: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    textPreview,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ------------------------- Write Journal Page ------------------------------
class WriteJournalPage extends StatefulWidget {
  final String? initialDateLabel;
  const WriteJournalPage({this.initialDateLabel, Key? key}) : super(key: key);

  const WriteJournalPage.prototype({Key? key}) : this(initialDateLabel: null, key: key);

  @override
  State<WriteJournalPage> createState() => _WriteJournalPageState();
}

class _WriteJournalPageState extends State<WriteJournalPage> {
  late String _dateLabel;
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _bodyCtrl = TextEditingController();

  // moods available in assets (use your own images)
  final List<String> _moods = [
    'assets/images/sunrise.png',
    'assets/images/happy.png',
    'assets/images/tired.png',
  ];
  String _selectedMood = 'assets/images/sunrise.png';

  @override
  void initState() {
    super.initState();
    _dateLabel = widget.initialDateLabel ?? _formatDate(DateTime.now());
  }

  String _formatDate(DateTime d) => '${_weekdayName(d.weekday)}, ${_monthName(d.month)} ${d.day}';
  String _weekdayName(int w) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];
  String _monthName(int m) => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // top row: back, more, save + mood avatar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back)),
                    const Spacer(),
                    TextButton(
                      onPressed: _save,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Save', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // mood avatar
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withOpacity(0.6),
                      child: Image.asset(_selectedMood, width: 26, height: 26),
                    )
                  ],
                ),
              ),

              // content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_dateLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

              // bottom icon bar (all clickable IconButtons)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(onPressed: () => _onIconPressed('style'), icon: const Icon(Icons.format_paint)),
                    IconButton(onPressed: () => _onIconPressed('image'), icon: const Icon(Icons.image)),
                    IconButton(onPressed: () => _onIconPressed('favorite'), icon: const Icon(Icons.star_border)),
                    IconButton(onPressed: () => _onIconPressed('emoji'), icon: const Icon(Icons.emoji_emotions_outlined)),
                    IconButton(onPressed: () => _onIconPressed('text'), icon: const Icon(Icons.text_fields)),
                    IconButton(onPressed: () => _onIconPressed('list'), icon: const Icon(Icons.format_list_bulleted)),
                    IconButton(onPressed: () => _onIconPressed('tag'), icon: const Icon(Icons.label_outline)),
                    IconButton(onPressed: () => _onIconPressed('mic'), icon: const Icon(Icons.mic_none)),
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
    // Prototype: simply show a SnackBar for now. You said you'll tell what they do later.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Icon: $action clicked')));
  }

  void _save() {
    // create a JournalEntryModel with the filled data and return it
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    final preview = (title.isNotEmpty) ? '$title - ${body.split('
').firstWhere((e) => e.isNotEmpty, orElse: () => '')}' : (body.split('
').firstWhere((e) => e.isNotEmpty, orElse: () => ''));

    final entry = JournalEntryModel(
      dateLabel: _dateLabel,
      moodImage: _selectedMood,
      textPreview: preview.isEmpty ? 'No content' : preview,
    );

    Navigator.of(context).pop(entry);
  }
}

// -------------------- Detail Page (view only) ------------------------------
class JournalDetailPage extends StatelessWidget {
  final JournalEntryModel entry;
  const JournalDetailPage({required this.entry, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Journal')),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.dateLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              Row(children: [Image.asset(entry.moodImage, height: 40), const SizedBox(width: 12), Expanded(child: Text(entry.textPreview))]),
            ],
          ),
        ),
      ),
    );
  }
}



