import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';

class ImageQuoteCard extends StatelessWidget {
  final String imagePath;
  final String quote;
  const ImageQuoteCard({super.key, required this.imagePath, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 130,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(.25)),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  quote,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.3,
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
