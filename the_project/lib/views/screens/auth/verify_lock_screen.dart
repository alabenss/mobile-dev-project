
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

  Widget _buildPinInput(AppLockState state) {
    return Column(
      children: [
        TextField(
          controller: _inputController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 24,
            letterSpacing: 8,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '••••••',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _showError ? AppColors.error : AppColors.textSecondary,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _showError ? AppColors.error : AppColors.textSecondary,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _showError ? AppColors.error : AppColors.accentPink,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.card,
            counterText: "",
          ),
          onChanged: (value) {
            if (_showError) setState(() => _showError = false);
            if (value.length == 6) {
              // Auto-verify when 6 digits entered
              _verifyLock(context, state);
            }
          },
          autofocus: true,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _verifyLock(context, state),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentPink,
            foregroundColor: AppColors.kLight,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.check, size: 24),
          label: Text(
            'Verify PIN',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatternInput(AppLockState state) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          PatternLockWidget(
            points: _patternPoints,
            onPatternDraw: (points) {
              setState(() {
                _patternPoints = points;
                _showError = false;
              });
              
              // Auto-submit when pattern has at least 4 points
              if (_patternPoints.length >= 4) {
                _verifyLock(context, state);
              }
            },
          ),
          const SizedBox(height: 16),
          if (_patternPoints.isNotEmpty) ...[
            ElevatedButton.icon(
              onPressed: () => _verifyLock(context, state),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPink,
                foregroundColor: AppColors.kLight,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.check, size: 24),
              label: Text(
                'Verify Pattern',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _clearPattern,
              icon: const Icon(Icons.refresh, size: 20),
              label: Text(
                'Redraw Pattern',
                style: GoogleFonts.poppins(
                  color: AppColors.accentPink,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPasswordInput(AppLockState state) {
    return Column(
      children: [
        TextField(
          controller: _inputController,
          obscureText: true,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Enter password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _showError ? AppColors.error : AppColors.textSecondary,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _showError ? AppColors.error : AppColors.textSecondary,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: _showError ? AppColors.error : AppColors.accentPink,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.card,
          ),
          onChanged: (value) {
            if (_showError) setState(() => _showError = false);
          },
          onSubmitted: (value) => _verifyLock(context, state),
          autofocus: true,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _verifyLock(context, state),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentPink,
            foregroundColor: AppColors.kLight,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: const Icon(Icons.check, size: 24),
          label: Text(
            'Verify Password',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
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
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.accentPink.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 80,
                        color: AppColors.accentPink,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Enter ${_getLockTypeLabel(state.lockType, l10n).toLowerCase()} to unlock',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Input field based on lock type
                    if (state.lockType == 'pin') 
                      _buildPinInput(state)
                    else if (state.lockType == 'pattern') 
                      _buildPatternInput(state)
                    else if (state.lockType == 'password') 
                      _buildPasswordInput(state),

                    const SizedBox(height: 32),

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
