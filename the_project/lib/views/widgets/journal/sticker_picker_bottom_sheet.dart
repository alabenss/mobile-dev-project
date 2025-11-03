
import 'package:flutter/material.dart';

class StickerPickerBottomSheet extends StatelessWidget {
  final Function(String stickerPath) onStickerSelected;

  const StickerPickerBottomSheet({
    Key? key,
    required this.onStickerSelected,
  }) : super(key: key);

  // Liste des stickers disponibles
  static const List<String> _stickers = [
    'assets/images/stickers/sticker1.png',
    'assets/images/stickers/sticker2.png',
    'assets/images/stickers/sticker3.png',
    'assets/images/stickers/sticker4.png',
    'assets/images/stickers/sticker5.png',
    'assets/images/stickers/sticker6.png',
    'assets/images/stickers/sticker7.png',
    'assets/images/stickers/sticker8.png',
    'assets/images/stickers/sticker9.png',
    'assets/images/stickers/sticker10.png',
    'assets/images/stickers/sticker11.png',
    'assets/images/stickers/sticker12.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Sticker',
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
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _stickers.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    onStickerSelected(_stickers[index]);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      _stickers[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}