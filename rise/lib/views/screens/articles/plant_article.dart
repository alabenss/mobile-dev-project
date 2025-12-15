import 'package:flutter/material.dart';
import 'package:the_project/l10n/app_localizations.dart';
import '../../../commons/constants.dart';
import '../../themes/style_simple/colors.dart';
import '../../widgets/home/article_appbar.dart';

class PlantArticlePage extends StatelessWidget {
  const PlantArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // <-- added

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
        appBar: ArticleAppBar(
          title: l10n.plantArticleTitle, // was: 'The calming effect of plants'
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            children: [
              // Hero image
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Image.asset(
                      AppImages.plantsHero,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 180,
                      color: Colors.black.withOpacity(.15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Article card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.95),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column( // <-- removed const
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.plantArticleIntro,
                      // was: 'Greenery does more than decorate your space — it relaxes your mind. '
                      //      'Caring for a plant slows you down and brings your focus to the present moment.'
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.plantArticleBenefitsTitle, // was: 'Benefits at a glance'
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Bullet(text: l10n.plantArticleBullet1),
                    // was: 'Reduces stress and mental fatigue'
                    _Bullet(text: l10n.plantArticleBullet2),
                    // was: 'Improves focus and creativity'
                    _Bullet(text: l10n.plantArticleBullet3),
                    // was: 'Adds gentle, natural color to your room'
                    _Bullet(text: l10n.plantArticleBullet4),
                    // was: 'Creates a tiny daily ritual (water, prune, observe)'
                    const SizedBox(height: 14),
                    _Quote(
                      text: l10n.plantArticleQuote,
                      // was: '“To nurture a garden is to feed not just the body, but the soul.”'
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.plantArticleTipTitle, // was: 'Tip of the day'
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.plantArticleTipBody,
                      // was: 'Place one small plant near where you work most. '
                      //      'Check in with it once a day — a 30-second reset for your brain.'
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: AppColors.textPrimary,
                      ),
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
                      right: 8,
                      bottom: 6,
                      child: Image.asset(
                        AppImages.plantIcon,
                        width: 76,
                        height: 76,
                      ),
                    ),
                    Padding( // <-- removed const
                      padding: const EdgeInsets.all(14.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.plantArticleFooter,
                          // was: 'Keep growing — one leaf at a time 🌿'
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
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
          const Icon(
            Icons.eco_rounded,
            size: 18,
            color: AppColors.accentGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
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
        style: const TextStyle(
          fontStyle: FontStyle.italic,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
