import 'package:flutter/material.dart';
import 'package:the_project/l10n/app_localizations.dart';
import '../../themes/style_simple/colors.dart';

class JournalBottomToolbar extends StatelessWidget {
  final VoidCallback onBackground;
  final VoidCallback onPickImage;
  final VoidCallback onStickers;
  final VoidCallback onTextStyle;
  final VoidCallback onVoiceNote;

  const JournalBottomToolbar({
    super.key,
    required this.onBackground,
    required this.onPickImage,
    required this.onStickers,
    required this.onTextStyle,
    required this.onVoiceNote,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      color: AppColors.card.withOpacity(0.95),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: onBackground,
            icon: const Icon(Icons.wallpaper),
            tooltip: l10n.journalToolbarBackground,
          ),
          IconButton(
            onPressed: onPickImage,
            icon: const Icon(Icons.photo),
            tooltip: l10n.journalToolbarAddImage,
          ),
          IconButton(
            onPressed: onStickers,
            icon: const Icon(Icons.sticky_note_2_outlined),
            tooltip: l10n.journalToolbarStickers,
          ),
          IconButton(
            onPressed: onTextStyle,
            icon: const Icon(Icons.text_fields),
            tooltip: l10n.journalToolbarTextStyle,
          ),
          IconButton(
            onPressed: onVoiceNote,
            icon: const Icon(Icons.mic),
            tooltip: l10n.journalToolbarVoiceNote,
          ),
        ],
      ),
    );
  }
}