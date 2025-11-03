
class JournalEntryModel {
  final String dateLabel;
  final DateTime date;
  final String moodImage;
  final String title;
  final String fullText;
  final bool isEmpty;
  
  // Propriétés pour le style
  final String? backgroundImage;
  final String? fontFamily;
  final String? textColor;
  final double? fontSize;
  final List<String>? attachedImages;
  
  // Stickers avec leurs positions
  final List<StickerData>? stickers;

  JournalEntryModel({
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
    this.stickers,
  }) : isEmpty = false;

  JournalEntryModel.empty()
      : dateLabel = '',
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
        stickers = null;
}

// Classe pour stocker les stickers avec positions
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
    x: json['x'],
    y: json['y'],
  );
}