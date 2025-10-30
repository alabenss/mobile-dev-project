import 'package:flutter/material.dart';

class BottomPillNav extends StatelessWidget {
  /// Currently selected tab index (0..4)
  final int index;

  /// Tap callback with the tapped index
  final ValueChanged<int> onTap;

  /// Colors (customizable but have defaults)
  final Color backgroundColor; // pill background
  final Color activeColor;     // tint/opacity for active item
  final Color inactiveColor;   // tint/opacity for inactive item
  final Color fabColor;        // center round button color

  /// Asset paths (optional – you can change names to match your files)
  final List<String> icons;

  const BottomPillNav({
    super.key,
    required this.index,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.activeColor = const Color(0xFFFF6E9A),
    this.inactiveColor = const Color(0xFF9D9D9D),
    this.fabColor = const Color(0xFF9B57F0),
    this.icons = const <String>[
      'assets/icons/home.png',
      'assets/icons/habits.png',
      'assets/icons/jouraling.png',
      'assets/icons/activities.png', // center FAB
      'assets/icons/statistics.png',
    ],
  }) : assert(icons.length == 5, 'icons must have 5 items');

  Widget _assetOrIcon(
    String path, {
    required bool active,
    IconData fallback = Icons.circle,
    double size = 28,
  }) {
    // Slight visual emphasis for the active item
    final double opacity = active ? 1.0 : 0.55;

    return Opacity(
      opacity: opacity,
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (ctx, err, st) => Icon(
          fallback,
          size: size,
          color: active ? activeColor : inactiveColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 74;
    const double fabSize = 56;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      color: Colors.transparent,
      child: Container(
        height: barHeight,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 12,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // row of the 4 side items (2 left, 2 right)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 0
                  _NavTap(
                    onTap: () => onTap(0),
                    child: _assetOrIcon(
                      icons[0],
                      active: index == 0,
                      fallback: Icons.home_rounded,
                    ),
                  ),
                  // 1
                  _NavTap(
                    onTap: () => onTap(1),
                    child: _assetOrIcon(
                      icons[1],
                      active: index == 1,
                      fallback: Icons.directions_walk,
                    ),
                  ),
                  const SizedBox(width: fabSize), // space for center FAB
                  // 3 (right of FAB – stats is actually index 4, journaling is 2)
                  _NavTap(
                    onTap: () => onTap(4),
                    child: _assetOrIcon(
                      icons[4],
                      active: index == 4,
                      fallback: Icons.query_stats_outlined,
                    ),
                  ),
                  _NavTap(
                    onTap: () => onTap(2),
                    child: _assetOrIcon(
                      icons[2],
                      active: index == 2,
                      fallback: Icons.edit_note_outlined,
                    ),
                  ),
                ],
              ),
            ),

            // raised center circular button (index 3)
            Align(
              alignment: Alignment.topCenter,
              child: Transform.translate(
                offset: const Offset(0, -18),
                child: GestureDetector(
                  onTap: () => onTap(3),
                  child: Container(
                    width: fabSize,
                    height: fabSize,
                    decoration: BoxDecoration(
                      color: fabColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      icons[3],
                      color: Colors.white,
                      errorBuilder: (c, e, s) =>
                          Icon(Icons.sports_kabaddi_outlined,
                              color: Colors.white),
                    ),
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

class _NavTap extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _NavTap({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10),
        child: child,
      ),
    );
    }
}
