import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';

class JournalBottomToolbar extends StatelessWidget {
  final VoidCallback onBackground;
  final VoidCallback onPickImage;
  final VoidCallback onStickers;
  final VoidCallback onTextStyle;

  const JournalBottomToolbar({
    super.key,
    required this.onBackground,
    required this.onPickImage,
    required this.onStickers,
    required this.onTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.card.withOpacity(0.95),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: onBackground,
            icon: const Icon(Icons.wallpaper),
            tooltip: 'Background',
          ),
          IconButton(
            onPressed: onPickImage,
            icon: const Icon(Icons.photo),
            tooltip: 'Add Image',
          ),
          IconButton(
            onPressed: onStickers,
            icon: const Icon(Icons.sticky_note_2_outlined),
            tooltip: 'Stickers',
          ),
          IconButton(
            onPressed: onTextStyle,
            icon: const Icon(Icons.text_fields),
            tooltip: 'Text Style',
          ),
         IconButton(
             onPressed: () {}, 
             icon: const Icon(Icons.mic),
              tooltip: 'Voice note',
            ),
        ],
      ),
    );
  }
}

