import 'package:flutter/material.dart';
import '../../themes/style_simple/app_background.dart';


class ActivityShell extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? bottomBar;

  final Gradient? backgroundGradient;

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

    final Widget shell = Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
 
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
              child: Row(
                children: [
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
                    color: Colors.white.withOpacity(.35),
                    child: child,
                  ),
                ),
              ),
            ),

            if (bottomBar != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: bottomBar!,
              ),
          ],
        ),
      ),
    );


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
