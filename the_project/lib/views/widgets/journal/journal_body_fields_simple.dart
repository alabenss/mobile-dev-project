import 'package:flutter/material.dart';
import 'package:the_project/l10n/app_localizations.dart';

class JournalBodyFieldsSimple extends StatelessWidget {
  final String dateLabel;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final String fontFamily;
  final Color textColor;
  final double fontSize;

  const JournalBodyFieldsSimple({
    super.key,
    required this.dateLabel,
    required this.titleController,
    required this.bodyController,
    required this.fontFamily,
    required this.textColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateLabel,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: textColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: l10n.journalTitle,
            border: InputBorder.none,
          ),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
            color: textColor,
          ),
        ),

        TextField(
          controller: bodyController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: 5,
          decoration: InputDecoration(
            hintText: l10n.journalWriteMore,
            border: InputBorder.none,
          ),
          style: TextStyle(
            fontFamily: fontFamily,
            color: textColor,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}