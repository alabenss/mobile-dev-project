
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_project/l10n/app_localizations.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';
import 'package:the_project/views/widgets/applock/lock_type_selection_widget.dart';
import 'package:the_project/views/widgets/applock/set_lock_step_widget.dart';
import 'package:the_project/views/widgets/applock/confirm_lock_step_widget.dart';
import 'package:the_project/logic/applock/app_lock_cubit.dart';

class AppLockScreen extends StatelessWidget {
  const AppLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppLockCubit()..loadLock(),
      child: const _AppLockScreenBody(),
    );
  }
}

class _AppLockScreenBody extends StatefulWidget {
  const _AppLockScreenBody();

  @override
  State<_AppLockScreenBody> createState() => _AppLockScreenBodyState();
}

class _AppLockScreenBodyState extends State<_AppLockScreenBody> {
  String? selectedLockType;
  int _currentStep = 0;
  bool _isChangingExistingLock = false;

  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  List<int> _patternPoints = [];
  List<int> _confirmPatternPoints = [];

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _selectLockType(String type) {
    setState(() {
      selectedLockType = type;
      _currentStep = 1;
      _pinController.clear();
      _confirmPinController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _patternPoints.clear();
      _confirmPatternPoints.clear();
    });
  }

  bool _validateStep1() {
    if (selectedLockType == 'pin') {
      return _pinController.text.length >= 4;
    } else if (selectedLockType == 'pattern') {
      return _patternPoints.length >= 4;
    } else if (selectedLockType == 'password') {
      return _passwordController.text.length >= 4;
    }
    return false;
  }

  bool _validateStep2() {
    if (selectedLockType == 'pin') {
      return _pinController.text == _confirmPinController.text;
    } else if (selectedLockType == 'pattern') {
      if (_patternPoints.length != _confirmPatternPoints.length) return false;
      for (int i = 0; i < _patternPoints.length; i++) {
        if (_patternPoints[i] != _confirmPatternPoints[i]) return false;
      }
      return true;
    } else if (selectedLockType == 'password') {
      return _passwordController.text == _confirmPasswordController.text;
    }
    return false;
  }

  Future<void> _saveLock(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    if (!_validateStep2() || selectedLockType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.appLockMismatch)),
      );
      return;
    }

    String lockValue = '';
    if (selectedLockType == 'pin') {
      lockValue = _pinController.text;
    } else if (selectedLockType == 'pattern') {
      lockValue = _patternPoints.join(',');
    } else if (selectedLockType == 'password') {
      lockValue = _passwordController.text;
    }

    final cubit = context.read<AppLockCubit>();
    await cubit.saveLock(selectedLockType!, lockValue);

    if (cubit.state.saveSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.appLockSaved)),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.appLockSaveError)),
      );
    }
  }

  Future<void> _removeLock(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.appLockRemoveConfirm),
        content: Text(l10n.appLockRemoveMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.appLockCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final cubit = context.read<AppLockCubit>();
              await cubit.removeLock();

              if (cubit.state.removeSuccess) {
                setState(() {
                  _currentStep = 0;
                  selectedLockType = null;
                  _isChangingExistingLock = false;
                  _pinController.clear();
                  _confirmPinController.clear();
                  _passwordController.clear();
                  _confirmPasswordController.clear();
                  _patternPoints.clear();
                  _confirmPatternPoints.clear();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.appLockRemoved)),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.appLockRemove, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _clearPattern() {
    setState(() => _patternPoints.clear());
  }

  void _clearConfirmPattern() {
    setState(() => _confirmPatternPoints.clear());
  }

  void _goBack() {
    if (_currentStep == 1) {
      setState(() {
        _currentStep = 0;
        selectedLockType = null;
        _isChangingExistingLock = false;
      });
    } else if (_currentStep == 2) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _startChangeLock() {
    setState(() {
      _isChangingExistingLock = true;
      _currentStep = 0;
      selectedLockType = null;
    });
  }

  Widget _buildLockStatusCard(AppLockState lockState, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock_outlined,
                  color: AppColors.accentPink,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appLockEnabled,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lockState.lockType!.toUpperCase()} Lock',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _startChangeLock,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(l10n.appLockChangeLock),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.card,
                      foregroundColor: AppColors.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _removeLock(context),
                    icon: const Icon(Icons.lock_open_outlined, size: 18),
                    label: Text(l10n.appLockRemove),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(AppLockState lockState, BuildContext context) {
    // If user has existing lock and not changing it, show status card
    if (lockState.lockType != null && !_isChangingExistingLock && _currentStep == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.appLockCurrentSettings,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          _buildLockStatusCard(lockState, context),
          const Spacer(),
        ],
      );
    }

    // Otherwise show the normal flow
    switch (_currentStep) {
      case 1:
        return SetLockStepWidget(
          selectedLockType: selectedLockType,
          pinController: _pinController,
          passwordController: _passwordController,
          patternPoints: _patternPoints,
          onPatternDraw: (points) => setState(() => _patternPoints = points),
          onClearPattern: _clearPattern,
          onContinue: () => setState(() => _currentStep = 2),
          validateStep: _validateStep1,
        );
      case 2:
        return ConfirmLockStepWidget(
          selectedLockType: selectedLockType,
          confirmPinController: _confirmPinController,
          confirmPasswordController: _confirmPasswordController,
          confirmPatternPoints: _confirmPatternPoints,
          onPatternDraw: (points) => setState(() => _confirmPatternPoints = points),
          onClearPattern: _clearConfirmPattern,
          onSaveLock: () => _saveLock(context),
          validateStep: _validateStep2,
        );
      default:
        return LockTypeSelectionWidget(
          currentLock: _isChangingExistingLock ? null : lockState.lockType,
          onLockTypeSelected: _selectLockType,
          onRemoveLock: () => _removeLock(context),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appLockTitle,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0 || _isChangingExistingLock
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                onPressed: _goBack,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<AppLockCubit, AppLockState>(
            builder: (context, state) {
              if (state.isLoading && _currentStep == 0) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildStepContent(state, context);
            },
          ),
        ),
      ),
    );
  }
}
