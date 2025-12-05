// lib/views/screens/activities/activities.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_project/l10n/app_localizations.dart';

import '../../widgets/activities/activity_card.dart';
import 'games/bubble_popper_game.dart';
import 'games/breathing_page.dart';
import 'games/painting_page.dart';
import 'games/coloring_page.dart';
import 'games/puzzle_game.dart';
import 'games/grow_plant.dart';
import '../../themes/style_simple/colors.dart';

import '../../../logic/activities/activities_cubit.dart';
import '../../../logic/activities/activities_state.dart';
import '../../../database/repo/activities_repo.dart';

import '../../../logic/activities/games/breathing_cubit.dart';
import '../../../logic/activities/games/bubble_popper_cubit.dart';
import '../../../logic/activities/games/puzzle_cubit.dart';
import '../../../logic/activities/games/painting_cubit.dart';
import '../../../logic/activities/games/coloring_cubit.dart';


class Activities extends StatelessWidget {
  const Activities({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // <-- added

    return BlocBuilder<ActivitiesCubit, ActivitiesState>(
      builder: (context, state) {
        if (state.isLoading && state.activities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(
            child: Text(
              l10n.failedToLoadActivities(state.error ?? ''),
              // was: 'Failed to load activities\n${state.error}'
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final List<ActivityItem> items = state.activities;

        // Map activity title -> page builder (navigation)
        final Map<String, WidgetBuilder> routes = {
          'Bubble Popper': (_) => BlocProvider(
                create: (_) => BubblePopperCubit(),
                child: const BubblePopperGame(),
              ),
          'Breathing': (_) => BlocProvider(
                create: (_) => BreathingCubit(),
                child: const BreathPage(),
              ),
          'Painting': (_) => BlocProvider(
                create: (_) => PaintingCubit(),
                child: const PaintingPage(),
              ),
          'Coloring': (_) => BlocProvider(
                create: (_) => ColoringCubit(),
                child: const ColoringPage(),
              ),
          'Puzzle': (_) => BlocProvider(
                create: (_) => PuzzleCubit(),
                child: const PuzzleGame(),
              ),
          'Grow the plant': (_) => const GrowPlantPage(),
        };

        // Convert ActivityItem -> UI data object
        final cards = <_MoodCardData>[
          for (final a in items)
            _MoodCardData(
              title: a.title,
              subtitle: a.subtitle,
              asset: a.asset,
            ),
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                    bg: AppColors.card,
                    border: AppColors.textPrimary,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

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
