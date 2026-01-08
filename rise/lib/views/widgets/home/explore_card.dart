import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';

class ExploreCard extends StatelessWidget {
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

  bool _isValidHttpUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.contains('\n') || trimmed.contains('\r') || trimmed.contains('\t')) return false;

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;
    if (!(uri.scheme == 'http' || uri.scheme == 'https')) return false;
    if (uri.host.isEmpty) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final trimmedUrl = imageUrl?.trim() ?? '';
    final canUseNetwork = _isValidHttpUrl(trimmedUrl);

    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (canUseNetwork)
            Positioned(
              right: 8,
              bottom: 6,
              child: Image.network(
                trimmedUrl,
                width: 90,
                height: 90,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            )
          else if (assetImage != null)
            Positioned(
              right: 8,
              bottom: 6,
              child: Image.asset(
                assetImage!,
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              ),
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
