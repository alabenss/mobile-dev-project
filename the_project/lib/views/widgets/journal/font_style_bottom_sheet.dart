
import 'package:flutter/material.dart';

class FontStyleBottomSheet extends StatefulWidget {
  final String currentFontFamily;
  final Color currentColor;
  final double currentFontSize;
  final Function(String fontFamily, Color color, double fontSize) onStyleChanged;

  const FontStyleBottomSheet({
    super.key,
    required this.currentFontFamily,
    required this.currentColor,
    required this.currentFontSize,
    required this.onStyleChanged,
  });

  @override
  State<FontStyleBottomSheet> createState() => _FontStyleBottomSheetState();
}

class _FontStyleBottomSheetState extends State<FontStyleBottomSheet> {
  late String _selectedFont;
  late Color _selectedColor;
  late double _selectedSize;

  final List<String> _fonts = [
    'Roboto',
    'Arial',
    'Courier',
    'Times New Roman',
    'Georgia',
    'Verdana',
  ];

  final List<Color> _colors = [
    Colors.black,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _selectedFont = widget.currentFontFamily;
    _selectedColor = widget.currentColor;
    _selectedSize = widget.currentFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Text Style',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // A small grabber — also hints there is scrollable content
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Font Family Selector
                  const Text(
                    'Font Family',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _fonts.map((font) {
                      final isSelected = _selectedFont == font;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedFont = font);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            font,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Color Selector
                  const Text(
                    'Text Color',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _colors.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedColor = color);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: Colors.black,
                                    width: 3,
                                  )
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Font Size Slider
                  const Text(
                    'Font Size',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _selectedSize,
                          min: 12,
                          max: 32,
                          divisions: 20,
                          label: _selectedSize.round().toString(),
                          onChanged: (value) {
                            setState(() => _selectedSize = value);
                          },
                        ),
                      ),
                      Text(
                        '${_selectedSize.round()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Add some bottom padding so it's clear content can scroll
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Visual divider/shadow to hint there is a footer button
          Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.03),
                  Colors.black.withOpacity(0.08),
                ],
              ),
            ),
          ),

          // Footer: Apply button — outside scroll, always visible
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: SizedBox(
                width: 180, // 👈 Set your desired width
  height: 45, // 👈 Set your desired height
                child: ElevatedButton(
                  onPressed: () {
                    widget.onStyleChanged(
                      _selectedFont,
                      _selectedColor,
                      _selectedSize,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
