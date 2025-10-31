import 'package:flutter/material.dart';
import '../../../commons/constants.dart';
import '../../themes/style_simple/colors.dart';
import '../../widgets/article_appbar.dart';

class SportArticlePage extends StatelessWidget {
  const SportArticlePage({super.key});

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
        appBar: const ArticleAppBar(title: 'Boost your mood with sports'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            children: [
              // Hero banner with gradient
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD7E6FF), Color(0xFFFFE0F0)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned(
                      right: 8, bottom: 6,
                      child: Image.asset(AppImages.boostMoodIcon, width: 120),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'A little motion\ncreates a lot of emotion 💪✨',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Article
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
                      'Moving your body is one of the fastest ways to lift your mood. '
                      'Activity releases endorphins — your brain’s natural “feel-good” chemicals.',
                      style: TextStyle(fontSize: 15, height: 1.45, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Easy ways to start',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 8),
                    _Bullet(text: '5–10 minute walk after meals'),
                    _Bullet(text: '1 song dance break while making coffee'),
                    _Bullet(text: 'Light stretches while watching TV'),
                    _Bullet(text: 'Invite a friend for a short jog or cycle'),
                    SizedBox(height: 14),
                    _Quote(text: 'Show up for 5 minutes. Most days, that’s all it takes to start.'),
                    SizedBox(height: 14),
                    Text(
                      'Remember',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Pick a movement that makes you smile — not just one that makes you sweat. '
                      'Joy builds consistency, and consistency lifts mood.',
                      style: TextStyle(fontSize: 15, height: 1.45, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // CTA to Activities (hook this later)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // TODO: navigate to Activities page when it’s ready
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start an activity'),
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
          const Icon(Icons.directions_run, size: 18, color: AppColors.accentBlue),
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
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBDD2FF)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.textPrimary),
      ),
    );
  }
}
