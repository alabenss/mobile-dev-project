
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/app_background.dart';
import '../../widgets/journal/journal_entry_model.dart';
import '../../widgets/journal/sticker_picker_bottom_sheet.dart';
import '../../widgets/journal/background_picker_bottom_sheet.dart';
import '../../widgets/journal/font_style_bottom_sheet.dart';

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

  // Style properties
  String _backgroundImage = '';
  String _fontFamily = 'Roboto';
  Color _textColor = Colors.black;
  double _fontSize = 16.0;
  
  // Image attachments et stickers
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
      
      // Charger les styles sauvegardés
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
      body: Stack(
        children: [
          // Background image si sélectionné
          if (_backgroundImage.isNotEmpty)
            Positioned.fill(
              child: Image.asset(
                _backgroundImage,
                fit: BoxFit.cover,
              ),
            ),
          
          // Overlay semi-transparent pour lisibilité
          if (_backgroundImage.isNotEmpty)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Container(
                  color: Colors.white.withOpacity(0.9),
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
                
                // Content area avec scroll
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date
                        Text(
                          _dateLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: _textColor,
                            fontFamily: _fontFamily,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Title
                        TextField(
                          controller: _titleCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Title',
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: _fontFamily,
                            color: _textColor,
                          ),
                        ),
                        
                        // Body
                        TextField(
                          controller: _bodyCtrl,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          minLines: 5,
                          decoration: const InputDecoration(
                            hintText: 'Write more here...',
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            color: _textColor,
                            fontSize: _fontSize,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Stickers ajoutés
                        if (_stickerPaths.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _stickerPaths.asMap().entries.map((entry) {
                              return Stack(
                                children: [
                                  Image.asset(
                                    entry.value,
                                    width: 60,
                                    height: 60,
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _stickerPaths.removeAt(entry.key);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        
                        // Images attachées
                        if (_attachedImagePaths.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _attachedImagePaths.asMap().entries.map((entry) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(entry.value),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _attachedImagePaths.removeAt(entry.key);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Bottom toolbar
                Container(
                  color: Colors.white.withOpacity(0.95),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: _showBackgroundPicker,
                        icon: const Icon(Icons.wallpaper),
                        tooltip: 'Background',
                      ),
                      IconButton(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo),
                        tooltip: 'Add Image',
                      ),
                      IconButton(
                        onPressed: _showStickerPicker,
                        icon: const Icon(Icons.sticky_note_2_outlined),
                        tooltip: 'Stickers',
                      ),
                      IconButton(
                        onPressed: _showFontStylePicker,
                        icon: const Icon(Icons.text_fields),
                        tooltip: 'Text Style',
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStickerPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StickerPickerBottomSheet(
        onStickerSelected: (stickerPath) {
          setState(() {
            _stickerPaths.add(stickerPath);
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

    final entry = JournalEntryModel(
      dateLabel: _dateLabel,
      date: _selectedDate,
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
}


