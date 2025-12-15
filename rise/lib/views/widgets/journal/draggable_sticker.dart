import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';

class DraggableSticker extends StatefulWidget {
  final String stickerPath;
  final VoidCallback onDelete;
  final Offset initialPosition;
  final double initialScale;
  final ValueChanged<Offset>? onPositionChanged;
  final ValueChanged<double>? onScaleChanged;

  const DraggableSticker({
    super.key,
    required this.stickerPath,
    required this.onDelete,
    required this.initialPosition,
    this.initialScale = 1.0,
    this.onPositionChanged,
    this.onScaleChanged,
  });

  @override
  State<DraggableSticker> createState() => _DraggableStickerState();
}

class _DraggableStickerState extends State<DraggableSticker> {
  late Offset position;
  late double scale;
  double _baseScale = 1.0;
  bool isInteracting = false;

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition;
    scale = widget.initialScale;
  }

  void _handleScaleStart(ScaleStartDetails details) {
    setState(() {
      isInteracting = true;
      // Capture the current scale as the base for this gesture
      _baseScale = scale;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Calculate new scale relative to the base scale
      // details.scale starts at 1.0 for each gesture
      double newScale = (_baseScale * details.scale).clamp(0.2, 4.0);
      scale = newScale;

      // Update position based on focal point movement
      position += details.focalPointDelta;

      // Notify parent of changes
      widget.onPositionChanged?.call(position);
      widget.onScaleChanged?.call(scale);
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    // Keep the border visible briefly after interaction
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          isInteracting = false;
        });
      }
    });
  }

  void _handleTap() {
    setState(() {
      isInteracting = true;
    });
    
    // Show delete button for 2 seconds then hide
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isInteracting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the actual size of the sticker after scaling
    const double baseSize = 80.0;
    final double scaledSize = baseSize * scale;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: _handleTap,
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        child: SizedBox(
          width: scaledSize,
          height: scaledSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Sticker container with border
              Container(
                width: scaledSize,
                height: scaledSize,
                decoration: BoxDecoration(
                  border: isInteracting
                      ? Border.all(
                          color: AppColors.accentBlue.withOpacity(0.5),
                          width: 2,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.transparent,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    widget.stickerPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Delete button - positioned at top-right corner of the scaled sticker
              if (isInteracting)
                Positioned(
                  top: -10,
                  right: -10,
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
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
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