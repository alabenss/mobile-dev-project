import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';
import '../../themes/style_simple/styles.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;
  const SectionCard({super.key, required this.title, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppText.sectionTitle),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
