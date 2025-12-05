import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_project/l10n/app_localizations.dart';

import '../../../widgets/activities/activity_shell.dart';
import '../../../../logic/activities/games/puzzle_cubit.dart';
import '../../../../logic/activities/games/puzzle_state.dart';

class PuzzleGame extends StatelessWidget {
  const PuzzleGame({super.key});

  static const int _n = 3; // 3x3 sliding puzzle

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PuzzleCubit>();
    final l10n = AppLocalizations.of(context)!; // <-- added

    return ActivityShell(
      title: l10n.puzzleTitle, // was: 'Puzzle'
      child: Column(
        children: [
          // Top instruction + actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EB),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    l10n.puzzleInstruction,
                    // was: 'Slide the tiles to re-create the correct order.'
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.35,
                      color: Color(0xFF2B2B2B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => cubit.reset(shuffle: true),
                        icon: const Icon(
                          Icons.shuffle_rounded,
                          size: 18,
                        ),
                        label: Text(l10n.puzzleShuffle), // was: 'Shuffle'
                      ),
                      OutlinedButton.icon(
                        onPressed: () => cubit.reset(shuffle: false),
                        icon: const Icon(
                          Icons.restart_alt_rounded,
                          size: 18,
                        ),
                        label: Text(l10n.puzzleReset), // was: 'Reset'
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Board
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: BlocBuilder<PuzzleCubit, PuzzleState>(
                builder: (context, state) {
                  final tiles = state.tiles;
                  final showSolvedBanner = state.showSolvedBanner;

                  return LayoutBuilder(
                    builder: (context, c) {
                      final size = min(c.maxWidth, c.maxHeight);
                      return Center(
                        child: Stack(
                          children: [
                            Container(
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 8,
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.all(10),
                              child: GridView.builder(
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: _n,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                ),
                                itemCount: tiles.length,
                                itemBuilder: (_, i) {
                                  final v = tiles[i];
                                  if (v == 0) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF6F6F6),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                    );
                                  }
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => cubit.onTileTap(i),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 150),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFB8C9FF),
                                            Color(0xFF8EA8FF)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x1F000000),
                                            blurRadius: 6,
                                            offset: Offset(0, 3),
                                          )
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$v',
                                          style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Solved banner
                            if (showSolvedBanner)
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Center(
                                    child: Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2DBE7B),
                                        borderRadius:
                                            BorderRadius.circular(22),
                                      ),
                                      child: Text(
                                        l10n.puzzleSolved, // was: 'Solved! 🎉'
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
