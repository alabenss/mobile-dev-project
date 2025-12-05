class JournalEntryModel {
  final int? id; // Added ID for tracking in database
  final String dateLabel;
  final DateTime date;
  final String moodImage;
  final String title;
  final String fullText;
  final bool isEmpty;
  
  final String? backgroundImage;
  final String? fontFamily;
  final String? textColor;
  final double? fontSize;
  final List<String>? attachedImages;
  final String? voicePath; // NEW: Voice note path
  
  final List<StickerData>? stickers;

  JournalEntryModel({
    this.id,
    required this.dateLabel,
    required this.date,
    required this.moodImage,
    required this.title,
    this.fullText = '',
    this.backgroundImage,
    this.fontFamily,
    this.textColor,
    this.fontSize,
    this.attachedImages,
    this.voicePath, // NEW
    this.stickers,
  }) : isEmpty = false;

  JournalEntryModel.empty()
      : id = null,
        dateLabel = '',
        date = DateTime.now(),
        moodImage = '',
        title = '',
        fullText = '',
        isEmpty = true,
        backgroundImage = null,
        fontFamily = null,
        textColor = null,
        fontSize = null,
        attachedImages = null,
        voicePath = null, // NEW
        stickers = null;

  // Copy with method for updates
  JournalEntryModel copyWith({
    int? id,
    String? dateLabel,
    DateTime? date,
    String? moodImage,
    String? title,
    String? fullText,
    String? backgroundImage,
    String? fontFamily,
    String? textColor,
    double? fontSize,
    List<String>? attachedImages,
    String? voicePath, // NEW
    List<StickerData>? stickers,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      dateLabel: dateLabel ?? this.dateLabel,
      date: date ?? this.date,
      moodImage: moodImage ?? this.moodImage,
      title: title ?? this.title,
      fullText: fullText ?? this.fullText,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      fontFamily: fontFamily ?? this.fontFamily,
      textColor: textColor ?? this.textColor,
      fontSize: fontSize ?? this.fontSize,
      attachedImages: attachedImages ?? this.attachedImages,
      voicePath: voicePath ?? this.voicePath, // NEW
      stickers: stickers ?? this.stickers,
    );
  }
}

class StickerData {
  final String path;
  final double x;
  final double y;

  StickerData({
    required this.path,
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toJson() => {
    'path': path,
    'x': x,
    'y': y,
  };

  factory StickerData.fromJson(Map<String, dynamic> json) => StickerData(
    path: json['path'],
    x: json['x'].toDouble(),
    y: json['y'].toDouble(),
  );
}