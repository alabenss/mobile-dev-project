import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';

class DraggableSticker extends StatefulWidget {
  final String stickerPath;
  final VoidCallback onDelete;
  final Offset initialPosition;
  final ValueChanged<Offset>? onPositionChanged; 

  const DraggableSticker({
    super.key,
    required this.stickerPath,
    required this.onDelete,
    required this.initialPosition,
    this.onPositionChanged,
  });

  @override
  State<DraggableSticker> createState() => _DraggableStickerState();
}

class _DraggableStickerState extends State<DraggableSticker> {
  late Offset position;
  double scale = 1.0;
  double baseScale = 1.0;

  // Used to calculate translation during scale updates
  late Offset _startFocalPoint;
  late Offset _startPosition;

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the entire thing in Positioned so parent Stack can place it
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild, // allow inner taps (delete) to register
        onScaleStart: (details) {
          baseScale = scale;
          _startFocalPoint = details.focalPoint;
          _startPosition = position;
        },
        onScaleUpdate: (details) {
          setState(() {
            // Update scale
            scale = (baseScale * details.scale).clamp(0.5, 3.0);

            // Update translation based on focal point movement
            final Offset focalDelta = details.focalPoint - _startFocalPoint;
            position = _startPosition + focalDelta;

            // Report new position to parent if requested
            widget.onPositionChanged?.call(position);
          });
        },
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topLeft,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Sticker image container
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.accentBlue.withOpacity(0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                ),
                child: Image.asset(
                  widget.stickerPath,
                  fit: BoxFit.contain,
                ),
              ),

              // Delete button (top-right, slightly outside)
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  behavior: HitTestBehavior.translucent,
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

              // Resize icon (purely decorative here)
              Positioned(
                bottom: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.zoom_out_map,
                    color: AppColors.card,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

