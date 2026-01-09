import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';

class ExploreCard extends StatelessWidget {
  // 🔧 Set this to false to REMOVE ALL images in explore cards
  static const bool kShowExploreImages = true;

  final Color color;
  final String title;
  final String cta;

  final String? assetImage;
  final String? imageUrl;

  const ExploreCard({
    super.key,
    required this.color,
    required this.title,
    required this.cta,
    this.assetImage,
    this.imageUrl,
  });

  String _clean(String? u) => (u ?? '').trim();

  @override
  Widget build(BuildContext context) {
    final url = _clean(imageUrl);

    Widget imageWidget = const SizedBox.shrink();

    if (kShowExploreImages) {
      if (url.isNotEmpty) {
        imageWidget = Image.network(
          url,
          width: 90,
          height: 90,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            if (assetImage != null) {
              return Image.asset(
                assetImage!,
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              );
            }
            return const SizedBox.shrink();
          },
        );
      } else if (assetImage != null) {
        imageWidget = Image.asset(
          assetImage!,
          width: 90,
          height: 90,
          fit: BoxFit.contain,
        );
      }
    }

    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: 8,
            bottom: 6,
            child: imageWidget,
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    width: 150,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.25,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                if (cta.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textSecondary.withOpacity(0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      cta,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
