import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_project/l10n/app_localizations.dart';
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
  final DateTime? initialDate;
  final int? initialMonth;
  final int? initialYear;
  final JournalEntryModel? existingEntry;

  const WriteJournalScreen({
    this.initialDate,
    this.initialMonth,
    this.initialYear,
    super.key,
  }) : existingEntry = null;

  const WriteJournalScreen.edit({required this.existingEntry, super.key})
      : initialDate = null,
        initialMonth = null,
        initialYear = null;

  @override
  State<WriteJournalScreen> createState() => _WriteJournalScreenState();
}

class _WriteJournalScreenState extends State<WriteJournalScreen> {
  late DateTime _selectedDate;
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _bodyCtrl = TextEditingController();

  String _selectedMood = 'assets/images/good.png';

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
      if (widget.initialDate != null) {
        final baseDate = widget.initialDate!;
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
      } else {
        _selectedDate = DateTime.now();
      }
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

  String _formatDateLabel(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final weekday = _getLocalizedWeekday(l10n, date.weekday);
    final month = _getLocalizedMonthShort(l10n, date.month);
    return '$weekday, $month ${date.day}';
  }

  String _getLocalizedWeekday(AppLocalizations l10n, int weekday) {
    switch (weekday) {
      case 1: return l10n.journalCalendarMonday;
      case 2: return l10n.journalCalendarTuesday;
      case 3: return l10n.journalCalendarWednesday;
      case 4: return l10n.journalCalendarThursday;
      case 5: return l10n.journalCalendarFriday;
      case 6: return l10n.journalCalendarSaturday;
      case 7: return l10n.journalCalendarSunday;
      default: return '';
    }
  }

  String _getLocalizedMonthShort(AppLocalizations l10n, int month) {
    switch (month) {
      case 1: return l10n.journalMonthJan;
      case 2: return l10n.journalMonthFeb;
      case 3: return l10n.journalMonthMar;
      case 4: return l10n.journalMonthApr;
      case 5: return l10n.journalMonthMay;
      case 6: return l10n.journalMonthJun;
      case 7: return l10n.journalMonthJul;
      case 8: return l10n.journalMonthAug;
      case 9: return l10n.journalMonthSep;
      case 10: return l10n.journalMonthOct;
      case 11: return l10n.journalMonthNov;
      case 12: return l10n.journalMonthDec;
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateLabel = _formatDateLabel(context, _selectedDate);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: Stack(
          children: [
            if (_backgroundImage.isNotEmpty)
              Positioned.fill(
                child: Image.asset(
                  _backgroundImage,
                  fit: BoxFit.cover,
                ),
              ),

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
                    onSave: () => _save(l10n),
                    selectedMood: _selectedMood,
                    onMoodTap: _showMoodPicker,
                  ),

                  Expanded(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              JournalBodyFieldsSimple(
                                dateLabel: dateLabel,
                                titleController: _titleCtrl,
                                bodyController: _bodyCtrl,
                                fontFamily: _fontFamily,
                                textColor: _textColor,
                                fontSize: _fontSize,
                              ),

                              const SizedBox(height: 200),
                            ],
                          ),
                        ),

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

                  JournalBottomToolbar(
                    onBackground: _showBackgroundPicker,
                    onPickImage: () => _pickImage(l10n),
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

  Future<void> _pickImage(AppLocalizations l10n) async {
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
        SnackBar(content: Text(l10n.journalErrorPickingImage(e.toString()))),
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

  void _save(AppLocalizations l10n) {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.journalAddTitle)),
      );
      return;
    }

    final entry = JournalEntryModel(
      id: widget.existingEntry?.id,
      date: _selectedDate,
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