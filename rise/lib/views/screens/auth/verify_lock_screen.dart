
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_project/l10n/app_localizations.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';
import 'package:the_project/views/widgets/applock/pattern_lock_widget.dart';
import 'package:the_project/logic/applock/app_lock_cubit.dart';

class VerifyLockScreen extends StatefulWidget {
  const VerifyLockScreen({super.key});

  @override
  State<VerifyLockScreen> createState() => _VerifyLockScreenState();
}

class _VerifyLockScreenState extends State<VerifyLockScreen> {
  final TextEditingController _inputController = TextEditingController();
  List<int> _patternPoints = [];
  bool _showError = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _verifyLock(BuildContext context, AppLockState state) async {
    String input = '';
    
    if (state.lockType == 'pin' || state.lockType == 'password') {
      input = _inputController.text;
    } else if (state.lockType == 'pattern') {
      input = _patternPoints.join(',');
    }

    if (input.isEmpty) {
      setState(() => _showError = true);
      return;
    }

    await context.read<AppLockCubit>().verifyLock(input);
  }

  void _clearPattern() {
    setState(() {
      _patternPoints.clear();
      _showError = false;
    });
  }

  void _clearInput() {
    setState(() {
      _inputController.clear();
      _showError = false;
    });
  }

  String _getLockTypeLabel(String? lockType, AppLocalizations l10n) {
    switch (lockType) {
      case 'pin':
        return l10n.appLockPin;
      case 'pattern':
        return l10n.appLockPattern;
      case 'password':
        return l10n.appLockPassword;
      default:
        return '';
    }
  }

  void _showForgotLockDialog(BuildContext context, AppLockState state, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Forgot ${_getLockTypeLabel(state.lockType, l10n)}?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'To reset your lock, you will need to verify your identity. '
          'This will remove the current lock and you can set a new one.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Remove the lock
              await context.read<AppLockCubit>().removeLock();
              
              // Clear any input
              _clearInput();
              _clearPattern();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lock has been removed. You can set a new one in Settings.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text(
              'Reset Lock',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternInput(AppLockState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pattern Widget - Centered with proper sizing
        Container(
          width: 300,
          height: 300,
          alignment: Alignment.center,
          child: PatternLockWidget(
            points: _patternPoints,
            onPatternDraw: (points) {
              setState(() {
                _patternPoints = points;
                _showError = false;
              });
            },
          ),
        ),
        
        // Buttons - Centered below pattern
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Redraw Button
            if (_patternPoints.isNotEmpty)
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: _clearPattern,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.card,
                    foregroundColor: AppColors.textPrimary,
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.textSecondary.withOpacity(0.2)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.refresh, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Redraw',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            if (_patternPoints.isNotEmpty) const SizedBox(width: 16),
            
            // Verify Button for Pattern
            SizedBox(
              width: _patternPoints.isNotEmpty ? 140 : 200,
              child: ElevatedButton(
                onPressed: _patternPoints.isNotEmpty
                    ? () => _verifyLock(context, state)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _patternPoints.isNotEmpty
                      ? AppColors.accentPink
                      : AppColors.textSecondary.withOpacity(0.3),
                  foregroundColor: AppColors.kLight,
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: AppColors.accentPink.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Verify',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AppLockCubit, AppLockState>(
      listener: (context, state) {
        if (state.wrongAttempt) {
          setState(() => _showError = true);
          _inputController.clear();
          _clearPattern();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Wrong ${_getLockTypeLabel(state.lockType, l10n).toLowerCase()}. Please try again.',
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lock Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.accentPink.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 60,
                        color: AppColors.accentPink,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'Enter ${_getLockTypeLabel(state.lockType, l10n).toLowerCase()} to unlock',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome back!',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Pattern input - only show for pattern lock type
                    if (state.lockType == 'pattern') 
                      _buildPatternInput(state),

                    const SizedBox(height: 40),

                    // Forgot lock option
                    TextButton(
                      onPressed: () => _showForgotLockDialog(context, state, l10n),
                      child: Text(
                        'Forgot ${_getLockTypeLabel(state.lockType, l10n).toLowerCase()}?',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
