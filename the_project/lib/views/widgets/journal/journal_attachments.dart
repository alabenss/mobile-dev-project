import 'package:flutter/material.dart';

class JournalAttachments extends StatelessWidget {
  final List<String> stickerPaths;
  final void Function(int index) onRemoveSticker;

  const JournalAttachments({
    super.key,
    required this.stickerPaths,
    required this.onRemoveSticker,
  });

  @override
  Widget build(BuildContext context) {
    if (stickerPaths.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: stickerPaths.asMap().entries.map((entry) {
        final idx = entry.key;
        final path = entry.value;
        return Stack(
          children: [
            Image.asset(
              path,
              width: 60,
              height: 60,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => onRemoveSticker(idx),
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
    );
  }
}

