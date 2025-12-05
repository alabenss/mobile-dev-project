// ============= set_lock_step_widget.dart =============
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_project/l10n/app_localizations.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';
import 'pattern_lock_widget.dart';

class SetLockStepWidget extends StatefulWidget {
  final String? selectedLockType;
  final TextEditingController pinController;
  final TextEditingController passwordController;
  final List<int> patternPoints;
  final Function(List<int>) onPatternDraw;
  final VoidCallback onClearPattern;
  final VoidCallback onContinue;
  final bool Function() validateStep;

  const SetLockStepWidget({
    super.key,
    required this.selectedLockType,
    required this.pinController,
    required this.passwordController,
    required this.patternPoints,
    required this.onPatternDraw,
    required this.onClearPattern,
    required this.onContinue,
    required this.validateStep,
  });

  @override
  State<SetLockStepWidget> createState() => _SetLockStepWidgetState();
}

class _SetLockStepWidgetState extends State<SetLockStepWidget> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appLockSetYour(widget.selectedLockType?.toUpperCase() ?? ''),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.appLockCreateLock( widget.selectedLockType ?? ''),
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),

        if (widget.selectedLockType == "pin") ...[
          TextField(
            controller: widget.pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: l10n.appLockEnterPin,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: AppColors.kLight,
              counterText: "",
            ),
            onChanged: (value) => setState(() {}),
          ),
        ] else if (widget.selectedLockType == "pattern") ...[
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                PatternLockWidget(
                  points: widget.patternPoints,
                  onPatternDraw: widget.onPatternDraw,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.patternPoints.isEmpty
                      ? l10n.appLockDrawPattern
                      : l10n.appLockPointsSelected( '${widget.patternPoints.length}'),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (widget.patternPoints.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: widget.onClearPattern,
                    child: Text(
                      l10n.appLockRedrawPattern,
                      style: GoogleFonts.poppins(color: AppColors.accentPink),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ] else if (widget.selectedLockType == "password") ...[
          TextField(
            controller: widget.passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: l10n.appLockEnterPassword,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: AppColors.kLight,
            ),
            onChanged: (value) => setState(() {}),
          ),
        ],

        const Spacer(),

        ElevatedButton(
          onPressed: widget.validateStep() ? widget.onContinue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentPink,
            foregroundColor: AppColors.kLight,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(l10n.appLockContinue),
        ),
      ],
    );
  }
}