import 'dart:io';
import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';

class JournalBodyFields extends StatelessWidget {
  final String dateLabel;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final String fontFamily;
  final Color textColor;
  final double fontSize;
  final List<String> attachedImagePaths;
  final void Function(int index) onRemoveAttachedImage;

  const JournalBodyFields({
    super.key,
    required this.dateLabel,
    required this.titleController,
    required this.bodyController,
    required this.fontFamily,
    required this.textColor,
    required this.fontSize,
    required this.attachedImagePaths,
    required this.onRemoveAttachedImage,
  });

  @override
  Widget build(BuildContext context) {
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

        // Title
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: 'Title',
            border: InputBorder.none,
          ),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
            color: textColor,
          ),
        ),

        // Body
        TextField(
          controller: bodyController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: 5,
          decoration: const InputDecoration(
            hintText: 'Write more here...',
            border: InputBorder.none,
          ),
          style: TextStyle(
            fontFamily: fontFamily,
            color: textColor,
            fontSize: fontSize,
          ),
        ),

        const SizedBox(height: 16),

        // Images attachées
        if (attachedImagePaths.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: attachedImagePaths.asMap().entries.map((entry) {
              final idx = entry.key;
              final path = entry.value;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(path),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => onRemoveAttachedImage(idx),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.card,
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
    );
  }
}

