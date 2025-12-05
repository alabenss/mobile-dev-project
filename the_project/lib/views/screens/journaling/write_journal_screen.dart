import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../themes/style_simple/colors.dart';
import '../../widgets/journal/journal_entry_model.dart';
import '../../widgets/journal/sticker_picker_bottom_sheet.dart';
import '../../widgets/journal/background_picker_bottom_sheet.dart';
import '../../widgets/journal/mood_picker_bottom_sheet.dart';
import '../../widgets/journal/voice_recorder_widget.dart';
import '../../widgets/journal/voice_note_player.dart';
import '../../themes/style_simple/app_background.dart';
import '../../widgets/journal/font_style_bottom_sheet.dart';
import '../../widgets/journal/journal_top_bar.dart';
import '../../widgets/journal/journal_body_fields_simple.dart';
import '../../widgets/journal/journal_bottom_toolbar.dart';
import '../../widgets/journal/draggable_sticker.dart';
import '../../widgets/journal/draggable_image.dart';

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
  }) : existingEntry = null;

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

  String _selectedMood = 'assets/images/good.png';

  // Style properties
  String _backgroundImage = '';
  String _fontFamily = 'Roboto';
  Color _textColor = AppColors.textPrimary;
  double _fontSize = 16.0;

  final List<ImageData> _attachedImages = [];
  final List<StickerData> _stickers = [];
  String? _voiceNotePath;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if (widget.existingEntry != null) {
      // EDITING: Use the existing entry's date
      _dateLabel = widget.existingEntry!.dateLabel;
      _selectedDate = widget.existingEntry!.date;
      _titleCtrl.text = widget.existingEntry!.title;
      _bodyCtrl.text = widget.existingEntry!.fullText;
      _selectedMood = widget.existingEntry!.moodImage;

      _backgroundImage = widget.existingEntry!.backgroundImage ?? '';
      _fontFamily = widget.existingEntry!.fontFamily ?? 'Roboto';
      _fontSize = widget.existingEntry!.fontSize ?? 16.0;

      if (widget.existingEntry!.textColor != null) {
        _textColor = _colorFromHex(widget.existingEntry!.textColor!);
      }

      if (widget.existingEntry!.attachedImages != null) {
        _attachedImages.addAll(widget.existingEntry!.attachedImages!);
      }

      if (widget.existingEntry!.stickers != null) {
        _stickers.addAll(widget.existingEntry!.stickers!);
      }

      _voiceNotePath = widget.existingEntry!.voicePath;
    } else {
      // CREATING NEW: Parse the date from initialDateLabel
      if (widget.initialDateLabel != null &&
          widget.initialMonth != null &&
          widget.initialYear != null) {
        final baseDate = _parseDateLabel(
          widget.initialDateLabel!,
          widget.initialMonth!,
          widget.initialYear!,
        );

        // ✅ Keep selected day, but attach current time so it's not 12:00 AM
        final now = DateTime.now();
        _selectedDate = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          now.hour,
          now.minute,
          now.second,
          now.millisecond,
          now.microsecond,
        );

        _dateLabel = widget.initialDateLabel!;
      } else {
        // Fallback to current date
        _selectedDate = DateTime.now();
        _dateLabel = _formatDate(_selectedDate);
      }
    }
  }

  DateTime _parseDateLabel(String label, int month, int year) {
    // Parse "Monday, Dec 1" format
    final parts = label.split(', ');
    if (parts.length != 2) return DateTime(year, month, 1);

    final dateParts = parts[1].split(' ');
    if (dateParts.length != 2) return DateTime(year, month, 1);

    final day = int.tryParse(dateParts[1]) ?? 1;
    return DateTime(year, month, day);
  }

  Color _colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  String _formatDate(DateTime d) =>
      '${_weekdayName(d.weekday)}, ${_monthName(d.month)} ${d.day}';

  String _weekdayName(int w) => [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ][w - 1];

  String _monthName(int m) => [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m - 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Stack(
          children: [
            // Background image if selected
            if (_backgroundImage.isNotEmpty)
              Positioned.fill(
                child: Image.asset(
                  _backgroundImage,
                  fit: BoxFit.cover,
                ),
              ),

            // Semi-transparent overlay for readability
            Positioned.fill(
              child: Container(
                color: AppColors.card.withOpacity(0.3),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  JournalTopBar(
                    onBack: () => Navigator.of(context).pop(),
                    onSave: _save,
                    selectedMood: _selectedMood,
                    onMoodTap: _showMoodPicker,
                  ),

                  Expanded(
                    child: Stack(
                      children: [
                        // Scrollable content
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Simple body fields (without images)
                              JournalBodyFieldsSimple(
                                dateLabel: _dateLabel,
                                titleController: _titleCtrl,
                                bodyController: _bodyCtrl,
                                fontFamily: _fontFamily,
                                textColor: _textColor,
                                fontSize: _fontSize,
                              ),

                              const SizedBox(height: 200), // Space for content
                            ],
                          ),
                        ),

                        // Draggable images overlay
                        ..._attachedImages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final image = entry.value;
                          return DraggableImage(
                            key: ValueKey('image_$index'),
                            imagePath: image.path,
                            initialPosition: Offset(image.x, image.y),
                            onDelete: () {
                              setState(() {
                                _attachedImages.removeAt(index);
                              });
                            },
                            onPositionChanged: (newPosition) {
                              final currentImage = _attachedImages[index];
                              _attachedImages[index] = ImageData(
                                path: currentImage.path,
                                x: newPosition.dx,
                                y: newPosition.dy,
                              );
                            },
                          );
                        }).toList(),

                        // Draggable stickers overlay
                        ..._stickers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final sticker = entry.value;
                          return DraggableSticker(
                            key: ValueKey('sticker_$index'),
                            stickerPath: sticker.path,
                            initialPosition: Offset(sticker.x, sticker.y),
                            initialScale: sticker.scale,
                            onDelete: () {
                              setState(() {
                                _stickers.removeAt(index);
                              });
                            },
                            onPositionChanged: (newPosition) {
                              final currentSticker = _stickers[index];
                              _stickers[index] = StickerData(
                                path: currentSticker.path,
                                x: newPosition.dx,
                                y: newPosition.dy,
                                scale: currentSticker.scale,
                              );
                            },
                            onScaleChanged: (newScale) {
                              final currentSticker = _stickers[index];
                              _stickers[index] = StickerData(
                                path: currentSticker.path,
                                x: currentSticker.x,
                                y: currentSticker.y,
                                scale: newScale,
                              );
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  // Voice note at bottom
                  if (_voiceNotePath != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: VoiceNotePlayer(
                        voicePath: _voiceNotePath!,
                        onDelete: () {
                          setState(() {
                            _voiceNotePath = null;
                          });
                        },
                      ),
                    ),

                  // Bottom toolbar
                  JournalBottomToolbar(
                    onBackground: _showBackgroundPicker,
                    onPickImage: _pickImage,
                    onStickers: _showStickerPicker,
                    onTextStyle: _showFontStylePicker,
                    onVoiceNote: _showVoiceRecorder,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoodPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => MoodPickerBottomSheet(
        currentMood: _selectedMood,
        onMoodSelected: (moodImage, moodLabel) {
          setState(() {
            _selectedMood = moodImage;
          });
        },
      ),
    );
  }

  void _showStickerPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StickerPickerBottomSheet(
        onStickerSelected: (path) {
          setState(() {
            _stickers.add(StickerData(
              path: path,
              x: 100,
              y: 200,
              scale: 1.0,
            ));
          });
        },
      ),
    );
  }

  void _showBackgroundPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => BackgroundPickerBottomSheet(
        onBackgroundSelected: (bgPath) {
          setState(() {
            _backgroundImage = bgPath;
          });
        },
      ),
    );
  }

  void _showFontStylePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FontStyleBottomSheet(
        currentFontFamily: _fontFamily,
        currentColor: _textColor,
        currentFontSize: _fontSize,
        onStyleChanged: (font, color, size) {
          setState(() {
            _fontFamily = font;
            _textColor = color;
            _fontSize = size;
          });
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        setState(() {
          _attachedImages.add(ImageData(
            path: image.path,
            x: 50,
            y: 150,
          ));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showVoiceRecorder() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => VoiceRecorderWidget(
        onRecordingComplete: (audioPath) {
          setState(() {
            _voiceNotePath = audioPath;
          });
        },
      ),
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

    // IMPORTANT: Use _selectedDate (the date of the journal entry)
    // NOT DateTime.now() - this ensures journal is saved on its correct day
    final entry = JournalEntryModel(
      id: widget.existingEntry?.id,
      dateLabel: _dateLabel,
      date: _selectedDate, // ✅ Uses the date from the selected day (+ now time for new entries)
      moodImage: _selectedMood,
      title: title,
      fullText: body,
      voicePath: _voiceNotePath,
      backgroundImage: _backgroundImage.isEmpty ? null : _backgroundImage,
      fontFamily: _fontFamily,
      textColor: _colorToHex(_textColor),
      fontSize: _fontSize,
      attachedImages: _attachedImages.isEmpty ? null : _attachedImages,
      stickers: _stickers.isEmpty ? null : _stickers,
    );

    Navigator.of(context).pop(entry);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }
}





