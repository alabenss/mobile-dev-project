import 'package:flutter/material.dart';

class BottomPillNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color circleColor;

  final List<String> icons;

  const BottomPillNav({
    super.key,
    required this.index,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0xFF9D9D9D),
    this.circleColor = const Color(0xFF9B57F0),
    this.icons = const <String>[
      'assets/icons/home.png',
      'assets/icons/habits.png',
      'assets/icons/jouraling.png',
      'assets/icons/activities.png',
      'assets/icons/statistics.png',
    ],
  }) : assert(icons.length == 5, 'icons must have 5 items');

  Widget _buildIcon({
    required int itemIndex,
    required String iconPath,
    required IconData fallback,
  }) {
    final bool isActive = index == itemIndex;

    // 🔮 If selected → wrap in a raised purple circle
    if (isActive) {
      return Transform.translate(
        offset: const Offset(0, -18),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: circleColor,
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
            iconPath,
            color: activeColor,
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, st) => Icon(fallback, color: activeColor),
          ),
        ),
      );
    }

    // 🩶 Otherwise → flat icon
    return Opacity(
      opacity: 0.6,
      child: Image.asset(
        iconPath,
        width: 28,
        height: 28,
        fit: BoxFit.contain,
        errorBuilder: (ctx, err, st) =>
            Icon(fallback, color: inactiveColor, size: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 74;

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 0 → Home
            _NavTap(
              onTap: () => onTap(0),
              child: _buildIcon(
                itemIndex: 0,
                iconPath: icons[0],
                fallback: Icons.home_rounded,
              ),
            ),
            // 1 → Habits
            _NavTap(
              onTap: () => onTap(1),
              child: _buildIcon(
                itemIndex: 1,
                iconPath: icons[1],
                fallback: Icons.directions_walk,
              ),
            ),
            // 2 → Journal
            _NavTap(
              onTap: () => onTap(2),
              child: _buildIcon(
                itemIndex: 2,
                iconPath: icons[2],
                fallback: Icons.edit_note_outlined,
              ),
            ),
            // 3 → Activities
            _NavTap(
              onTap: () => onTap(3),
              child: _buildIcon(
                itemIndex: 3,
                iconPath: icons[3],
                fallback: Icons.local_activity_outlined,
              ),
            ),
            // 4 → Stats
            _NavTap(
              onTap: () => onTap(4),
              child: _buildIcon(
                itemIndex: 4,
                iconPath: icons[4],
                fallback: Icons.query_stats_outlined,
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
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Center(child: child),
      ),
    );
  }
}
