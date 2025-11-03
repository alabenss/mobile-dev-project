  import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';

class BackgroundPickerBottomSheet extends StatelessWidget {
  final Function(String backgroundPath) onBackgroundSelected;

  const BackgroundPickerBottomSheet({
    super.key,
    required this.onBackgroundSelected,
  });

  static const List<String> _backgrounds = [
    'assets/images/background/bg1.jpg',
    'assets/images/background/bg2.jpg',
    'assets/images/background/bg3.jpg',
    'assets/images/background/bg4.jpg',
    'assets/images/background/bg5.jpg',
    'assets/images/background/bg6.jpg',
    'assets/images/background/bg7.jpg',
    'assets/images/background/bg8.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.card,
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
                  'Select Background',
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

          // Option "No Background"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: () {
                onBackgroundSelected('');
                Navigator.pop(context);
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'No Background',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.6, 
              ),
              itemCount: _backgrounds.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    onBackgroundSelected(_backgrounds[index]);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.textSecondary.withOpacity(0.3), width: 2),
                      image: DecorationImage(
                        image: AssetImage(_backgrounds[index]),
                        fit: BoxFit.cover,
                      ),
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