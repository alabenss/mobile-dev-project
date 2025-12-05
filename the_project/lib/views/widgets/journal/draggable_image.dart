import 'dart:io';
import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';

class DraggableImage extends StatefulWidget {
  final String imagePath;
  final VoidCallback onDelete;
  final Offset initialPosition;
  final ValueChanged<Offset>? onPositionChanged;

  const DraggableImage({
    super.key,
    required this.imagePath,
    required this.onDelete,
    required this.initialPosition,
    this.onPositionChanged,
  });

  @override
  State<DraggableImage> createState() => _DraggableImageState();
}

class _DraggableImageState extends State<DraggableImage> {
  late Offset position;
  bool isInteracting = false;

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () {
          setState(() {
            isInteracting = true;
          });
          
          // Hide after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                isInteracting = false;
              });
            }
          });
        },
        onPanStart: (details) {
          setState(() {
            isInteracting = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            position += details.delta;
            widget.onPositionChanged?.call(position);
          });
        },
        onPanEnd: (details) {
          setState(() {
            isInteracting = false;
          });
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Image with border when interacting
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                border: isInteracting
                    ? Border.all(
                        color: AppColors.accentBlue.withOpacity(0.5),
                        width: 2,
                      )
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Delete button (only when interacting)
            if (isInteracting)
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.card,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}