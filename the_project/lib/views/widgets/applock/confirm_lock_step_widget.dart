import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Confirm Your ${widget.selectedLockType?.toUpperCase()}",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Re-enter your ${widget.selectedLockType} to confirm",
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
              hintText: "Confirm your PIN",
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
                      ? "Draw your pattern again"
                      : "Points selected: ${widget.confirmPatternPoints.length}",
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
                      "Redraw Pattern",
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
              hintText: "Confirm your password",
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
            "Lock values don't match!",
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
          child: const Text("Save Lock"),
        ),
      ],
    );
  }
}