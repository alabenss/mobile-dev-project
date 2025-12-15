// ============= confirm_lock_step_widget.dart =============
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_project/l10n/app_localizations.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';
import 'pattern_lock_widget.dart';

class ConfirmLockStepWidget extends StatefulWidget {
  final String? selectedLockType;
  final TextEditingController confirmPinController;
  final TextEditingController confirmPasswordController;
  final List<int> confirmPatternPoints;
  final Function(List<int>) onPatternDraw;
  final VoidCallback onClearPattern;
  final VoidCallback onSaveLock;
  final bool Function() validateStep;

  const ConfirmLockStepWidget({
    super.key,
    required this.selectedLockType,
    required this.confirmPinController,
    required this.confirmPasswordController,
    required this.confirmPatternPoints,
    required this.onPatternDraw,
    required this.onClearPattern,
    required this.onSaveLock,
    required this.validateStep,
  });

  @override
  State<ConfirmLockStepWidget> createState() => _ConfirmLockStepWidgetState();
}

class _ConfirmLockStepWidgetState extends State<ConfirmLockStepWidget> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appLockConfirmYour( widget.selectedLockType?.toUpperCase() ?? ''),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.appLockReenterLock( widget.selectedLockType ?? ''),
          style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),

        if (widget.selectedLockType == "pin") ...[
          TextField(
            controller: widget.confirmPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: l10n.appLockConfirmPin,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: AppColors.card,
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
                  points: widget.confirmPatternPoints,
                  onPatternDraw: widget.onPatternDraw,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.confirmPatternPoints.isEmpty
                      ? l10n.appLockDrawPatternAgain
                      : l10n.appLockPointsSelected( '${widget.confirmPatternPoints.length}'),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (widget.confirmPatternPoints.isNotEmpty) ...[
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
            controller: widget.confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: l10n.appLockConfirmPassword,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: AppColors.card,
            ),
            onChanged: (value) => setState(() {}),
          ),
        ],

        const Spacer(),

        if (!widget.validateStep()) ...[
          Text(
            l10n.appLockMismatch,
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.error),
          ),
          const SizedBox(height: 8),
        ],

        ElevatedButton(
          onPressed: widget.validateStep() ? widget.onSaveLock : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentPink,
            foregroundColor: AppColors.textlight,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(l10n.appLockSaveLock),
        ),
      ],
    );
  }
}