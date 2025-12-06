class JournalEntryModel {
  final int? id;
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
  final List<ImageData>? attachedImages; // Changed from List<String>?
  final String? voicePath;
  
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
    this.voicePath,
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
        voicePath = null,
        stickers = null;

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
    List<ImageData>? attachedImages,
    String? voicePath,
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
      voicePath: voicePath ?? this.voicePath,
      stickers: stickers ?? this.stickers,
    );
  }
}

// NEW: ImageData class to store image path and position
class ImageData {
  final String path;
  final double x;
  final double y;

  ImageData({
    required this.path,
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toJson() => {
    'path': path,
    'x': x,
    'y': y,
  };

  factory ImageData.fromJson(Map<String, dynamic> json) => ImageData(
    path: json['path'] as String,
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
  );
}

class StickerData {
  final String path;
  final double x;
  final double y;
  final double scale;

  StickerData({
    required this.path,
    required this.x,
    required this.y,
    this.scale = 1.0,
  });

  Map<String, dynamic> toJson() => {
    'path': path,
    'x': x,
    'y': y,
    'scale': scale,
  };

  factory StickerData.fromJson(Map<String, dynamic> json) => StickerData(
    path: json['path'] as String,
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    scale: json['scale'] != null ? (json['scale'] as num).toDouble() : 1.0,
  );
}