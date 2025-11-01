class JournalEntryModel {
  final String dateLabel;
  final DateTime date;
  final String moodImage;
  final String title;
  final String fullText;
  final bool isEmpty;

  JournalEntryModel({
    required this.dateLabel,
    required this.date,
    required this.moodImage,
    required this.title,
    this.fullText = '',
  }) : isEmpty = false;

  JournalEntryModel.empty()
      : dateLabel = '',
        date = DateTime.now(),
        moodImage = '',
        title = '',
        fullText = '',
        isEmpty = true;
}