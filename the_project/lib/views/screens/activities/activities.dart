import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mood_card.dart';
import 'games/bubble_popper_game.dart';
import 'games/breathing_page.dart';
import 'games/painting_page.dart';
import 'games/coloring_page.dart';

class Activities extends StatelessWidget {
  const Activities({super.key});

  // Palette
  static const Color kBlack = Color(0xFF000000);
  static const Color kBeige = Color(0xFFFFEBC3);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kPurple = Color(0xFFBD69C7);
  static const Color kLight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final cards = <_MoodCardData>[
      _MoodCardData(
        title: 'Breathing',
        subtitle: 'Calm your mind with\ndeep breaths',
        asset: 'assets/images/breathing.png',
      ),
      _MoodCardData(
        title: 'Bubble Popper',
        subtitle: 'Find joy and calm in\nevery pop',
        asset: 'assets/images/popup.png',
      ),
      _MoodCardData(
        title: 'Painting',
        subtitle: 'Express your feelings\nthrough painting',
        asset: 'assets/images/painting.png',
      ),
      _MoodCardData(
        title: 'Puzzle',
        subtitle: 'Focus and have fun\nsolving puzzles',
        asset: 'assets/images/puzzle.png',
      ),
      _MoodCardData(
        title: 'Grow the plant',
        subtitle: 'Watch your own little\nplant thrive',
        asset: 'assets/images/planting.png',
      ),
      _MoodCardData(
        title: 'Coloring',
        subtitle: 'Relax with mindful\ncoloring',
        asset: 'assets/images/coloring.png',
      ),
    ];

    // Map card title -> page builder
    final Map<String, WidgetBuilder> routes = {
      'Bubble Popper': (_) => const BubblePopperGame(),
      'Breathing': (_) => const BreathPage(),
      'Painting': (_) => const PaintingPage(),
      'Coloring': (_) => const ColoringPage(),
      // 'Puzzle': (_) => const PuzzleGame(),
      // 'Grow the plant': (_) => const PlantGame(),
    };

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0, -1.0),
          end: Alignment(0, 0.9),
          colors: [Color(0xFFB85CCD), Color(0xFFE6A4D7), Color(0xFFFFEBC3)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ---------------- HEADER ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: kBeige,
                    backgroundImage: AssetImage('assets/icons/profile.png'),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Boost Your Mood',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        color: kBlack,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // ---------------- GRID ----------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _UniformGrid(
                  itemHeight: 208,
                  children: [
                    for (final c in cards)
                      InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: () {
                          final builder = routes[c.title];
                          if (builder != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: builder),
                            );
                          }
                        },
                        child: MoodCard(
                          data: c,
                          bg: kBeige,
                          border: kBlack,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- DATA + GRID --------------------

class _MoodCardData {
  final String title;
  final String subtitle;
  final String asset;
  const _MoodCardData({
    required this.title,
    required this.subtitle,
    required this.asset,
  });
}

class _UniformGrid extends StatelessWidget {
  final List<Widget> children;
  final double itemHeight;
  const _UniformGrid({
    required this.children,
    this.itemHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double itemWidth = (w - 16 * 2 - 16) / 2;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children
          .map(
            (child) => SizedBox(
              width: itemWidth,
              height: itemHeight,
              child: child,
            ),
          )
          .toList(),
    );
  }
}
