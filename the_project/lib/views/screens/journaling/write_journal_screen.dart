import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../themes/style_simple/colors.dart';
import '../../widgets/journal/journal_entry_model.dart';
import '../../widgets/journal/sticker_picker_bottom_sheet.dart';
import '../../widgets/journal/background_picker_bottom_sheet.dart';
import '../../widgets/journal/mood_picker_bottom_sheet.dart';
import '../../themes/style_simple/app_background.dart';
import '../../widgets/journal/font_style_bottom_sheet.dart';
import '../../widgets/journal/journal_top_bar.dart';
import '../../widgets/journal/journal_body_fields.dart';
import '../../widgets/journal/journal_attachments.dart';
import '../../widgets/journal/journal_bottom_toolbar.dart';

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

  final List<String> _attachedImagePaths = [];
  final List<String> _stickerPaths = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    if (widget.existingEntry != null) {
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
        _attachedImagePaths.addAll(widget.existingEntry!.attachedImages!);
      }
    } else {
      final now = DateTime.now();
      _selectedDate = widget.initialMonth != null && widget.initialYear != null
          ? DateTime(widget.initialYear!, widget.initialMonth!, now.day)
          : now;
      _dateLabel = widget.initialDateLabel ?? _formatDate(_selectedDate);
    }
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
                  // Top bar (with mood tap handler)
                  JournalTopBar(
                    onBack: () => Navigator.of(context).pop(),
                    onSave: _save,
                    selectedMood: _selectedMood,
                    onMoodTap: _showMoodPicker,
                  ),

                  // Scrollable content (body + attachments)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Body fields (date, title, body)
                          JournalBodyFields(
                            dateLabel: _dateLabel,
                            titleController: _titleCtrl,
                            bodyController: _bodyCtrl,
                            fontFamily: _fontFamily,
                            textColor: _textColor,
                            fontSize: _fontSize,
                            attachedImagePaths: _attachedImagePaths,
                            onRemoveAttachedImage: (index) {
                              setState(() {
                                _attachedImagePaths.removeAt(index);
                              });
                            },
                          ),

                          const SizedBox(height: 16),

                          // Stickers area
                          JournalAttachments(
                            stickerPaths: _stickerPaths,
                            onRemoveSticker: (index) {
                              setState(() {
                                _stickerPaths.removeAt(index);
                              });
                            },
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // Bottom toolbar
                  JournalBottomToolbar(
                    onBackground: _showBackgroundPicker,
                    onPickImage: _pickImage,
                    onStickers: _showStickerPicker,
                    onTextStyle: _showFontStylePicker,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show mood picker bottom sheet
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
            _stickerPaths.add(path);
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
          _attachedImagePaths.add(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
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

    // Determine if we're editing or creating
    final isEditing = widget.existingEntry != null;

    // Create entry
    final entry = JournalEntryModel(
      id: widget.existingEntry?.id, // PRESERVE ID when editing
      dateLabel: _dateLabel,
      date: isEditing 
          ? widget.existingEntry!.date  // Keep original date when editing
          : DateTime.now(),              // Use current time when creating new
      moodImage: _selectedMood,
      title: title,
      fullText: body,
      backgroundImage: _backgroundImage.isEmpty ? null : _backgroundImage,
      fontFamily: _fontFamily,
      textColor: _colorToHex(_textColor),
      fontSize: _fontSize,
      attachedImages: _attachedImagePaths.isEmpty ? null : _attachedImagePaths,
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




