import 'package:flutter/material.dart';
import 'app_background.dart';

/// Reusable wrapper for Activities pages.
/// - Unified gradient (via AppBackground)
/// - Transparent Scaffold
/// - Centered title with rounded back button
class ActivityShell extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? bottomBar;

  /// Optional override if you *really* want a one-off gradient on some page.
  /// If null (default), the global AppBackground gradient is used.
  final Gradient? backgroundGradient;

  /// Override title/back icon color if needed (defaults to white).
  final Color? titleColor;

  const ActivityShell({
    super.key,
    required this.title,
    required this.child,
    this.bottomBar,
    this.backgroundGradient,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color tColor = titleColor ?? Colors.white;

    // The page shell (Scaffold + header + content)
    final Widget shell = Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // ------- Header -------
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: Row(
                children: [
                  // Rounded back button
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: tColor,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Centered title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .2,
                      color: tColor,
                    ),
                  ),

                  const Spacer(),

                  // Right spacer (keep title perfectly centered)
                  const SizedBox(width: 42),
                ],
              ),
            ),

            // ------- Content -------
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    // Soft glassy panel over the gradient (tweak opacity if you want)
                    color: Colors.white.withOpacity(.35),
                    child: child,
                  ),
                ),
              ),
            ),

            // Optional bottom bar (kept if you pass it in)
            if (bottomBar != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: bottomBar!,
              ),
          ],
        ),
      ),
    );

    // Apply the unified background everywhere.
    // If you pass a custom gradient, we honor it for that page.
    if (backgroundGradient != null) {
      return Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: shell,
      );
    } else {
      return AppBackground(child: shell);
    }
  }
}
