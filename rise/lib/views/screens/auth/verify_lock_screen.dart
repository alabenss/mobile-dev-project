import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_project/l10n/app_localizations.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';
import 'package:the_project/views/widgets/applock/pattern_lock_widget.dart';
import 'package:the_project/logic/applock/app_lock_cubit.dart';
import 'package:the_project/logic/auth/auth_cubit.dart';
import 'package:the_project/main.dart';

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

  Future<void> _verifyLock(BuildContext context, AppLockState state) async {
    String input = '';

    if (state.lockType == 'pin' || state.lockType == 'password') {
      input = _inputController.text.trim();
    } else if (state.lockType == 'pattern') {
      input = _patternPoints.join(',');
    }

    if (input.isEmpty) {
      setState(() => _showError = true);
      return;
    }

    final cubit = context.read<AppLockCubit>();
    await cubit.verifyLock(input);

    final newState = cubit.state;

    // ✅ If correct: just unlock, and try to close route ONLY if possible
    if (newState.isAuthenticated) {
      if (!mounted) return;

      // If it was pushed as a route, close it.
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop(true);
      }
      // If it was not pushed (used inside wrapper), do nothing.
      return;
    }

    // ❌ wrong code
    setState(() => _showError = true);
    _clearInput();
    _clearPattern();
  }

void _showForgotLockDialog(
  BuildContext context,
  AppLockState state,
  AppLocalizations l10n,
) {
  final rootNav = Navigator.of(context, rootNavigator: true);

  showDialog(
    context: rootNav.context,
    useRootNavigator: true,
    builder: (dialogCtx) => AlertDialog(
      title: Text(
        'Forgot ${_getLockTypeLabel(state.lockType, l10n)}?',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      content: Text(
        'To reset your lock, you must log out and log back in to confirm your identity.',
        style: GoogleFonts.poppins(),
      ),
      actions: [
        TextButton(
          onPressed: () => rootNav.pop(),
          child: Text('No', style: GoogleFonts.poppins()),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () async {
  rootNav.pop(); // close dialog

  await context.read<AppLockCubit>().removeLock();
  await context.read<AuthCubit>().logout();

  // ✅ no navigation here — main.dart listener will redirect
},

          child: Text(
            'Log out',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}



  Widget _buildHeader(AppLockState state, AppLocalizations l10n) {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildPinOrPassword(AppLockState state, AppLocalizations l10n) {
    final isPin = state.lockType == 'pin';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _inputController,
          obscureText: true,
          keyboardType: isPin ? TextInputType.number : TextInputType.text,
          maxLength: isPin ? 6 : null,
          decoration: InputDecoration(
            hintText: isPin ? l10n.appLockEnterPin : l10n.appLockEnterPassword,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor: AppColors.card,
            counterText: "",
          ),
          onChanged: (_) => setState(() => _showError = false),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _verifyLock(context, state),
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

  Widget _buildPattern(AppLockState state, AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: Center(
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
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                      side: BorderSide(
                        color: AppColors.textSecondary.withOpacity(0.2),
                      ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Wrong ${_getLockTypeLabel(state.lockType, l10n).toLowerCase()}. Please try again.',
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );

          context.read<AppLockCubit>().clearTransientFlags();
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            width: double.infinity,
            height: double.infinity,
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
                  children: [
                    const SizedBox(height: 24),
                    _buildHeader(state, l10n),
                    const SizedBox(height: 24),
                    if (_showError)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Wrong. Please try again.',
                          style: GoogleFonts.poppins(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Center(
                        child: state.lockType == 'pattern'
                            ? _buildPattern(state, l10n)
                            : _buildPinOrPassword(state, l10n),
                      ),
                    ),

                    // ✅ Forgot button (works now)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        debugPrint('Forgot tapped ✅');
                        _showForgotLockDialog(context, state, l10n);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Forgot ${_getLockTypeLabel(state.lockType, l10n).toLowerCase()}?',
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
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
