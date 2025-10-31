import 'package:flutter/material.dart';
import '../../../commons/constants.dart';
import '../../themes/style_simple/colors.dart';
import '../../widgets/article_appbar.dart';

class PlantArticlePage extends StatelessWidget {
  const PlantArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const ArticleAppBar(title: 'The calming effect of plants'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            children: [
              // Hero image
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Image.asset(AppImages.plantsHero, height: 180, width: double.infinity, fit: BoxFit.cover),
                    Container(height: 180, color: Colors.black.withOpacity(.15)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Article card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.95),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                padding: const EdgeInsets.all(16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Greenery does more than decorate your space — it relaxes your mind. '
                      'Caring for a plant slows you down and brings your focus to the present moment.',
                      style: TextStyle(fontSize: 15, height: 1.45, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Benefits at a glance',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 8),
                    _Bullet(text: 'Reduces stress and mental fatigue'),
                    _Bullet(text: 'Improves focus and creativity'),
                    _Bullet(text: 'Adds gentle, natural color to your room'),
                    _Bullet(text: 'Creates a tiny daily ritual (water, prune, observe)'),
                    SizedBox(height: 14),
                    _Quote(
                      text: '“To nurture a garden is to feed not just the body, but the soul.”',
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Tip of the day',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Place one small plant near where you work most. '
                      'Check in with it once a day — a 30-second reset for your brain.',
                      style: TextStyle(fontSize: 15, height: 1.45, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Cute footer strip
              Container(
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFCDEFE3),
                  borderRadius: BorderRadius.circular(18),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned(
                      right: 8, bottom: 6,
                      child: Image.asset(AppImages.plantIcon, width: 76, height: 76),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Keep growing — one leaf at a time 🌿',
                          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.eco_rounded, size: 18, color: AppColors.accentGreen),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.45))),
        ],
      ),
    );
  }
}

class _Quote extends StatelessWidget {
  final String text;
  const _Quote({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFE7D2)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.textPrimary),
      ),
    );
  }
}
