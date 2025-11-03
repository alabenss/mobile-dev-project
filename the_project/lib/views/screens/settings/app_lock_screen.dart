import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';
import 'package:the_project/views/widgets/applock/lock_type_selection_widget.dart';
import 'package:the_project/views/widgets/applock/set_lock_step_widget.dart';
import 'package:the_project/views/widgets/applock/confirm_lock_step_widget.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  String? selectedLockType;
  String? currentLock;
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  List<int> _patternPoints = [];
  List<int> _confirmPatternPoints = [];
  int _currentStep = 0; // 0: choose type, 1: set lock, 2: confirm lock

  @override
  void initState() {
    super.initState();
    _loadLockSettings();
  }

  Future<void> _loadLockSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLockType = prefs.getString('lock_type');
      currentLock = prefs.getString('lock_value');
    });
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

  void _goBack() {
    if (_currentStep == 1) {
      setState(() {
        _currentStep = 0;
        selectedLockType = null;
      });
    } else if (_currentStep == 2) {
      setState(() {
        _currentStep = 1;
      });
    }
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
      return _patternPoints.length == _confirmPatternPoints.length &&
          _patternPoints.every(
            (point) => _confirmPatternPoints.contains(point),
          );
    } else if (selectedLockType == 'password') {
      return _passwordController.text == _confirmPasswordController.text;
    }
    return false;
  }

  Future<void> _saveLock() async {
    if (!_validateStep2()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lock values don't match!")));
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

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lock_type', selectedLockType!);
    await prefs.setString('lock_value', lockValue);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("App lock saved successfully!")),
    );

    Navigator.pop(context);
  }

  Future<void> _removeLock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lock_type');
    await prefs.remove('lock_value');

    setState(() {
      selectedLockType = null;
      currentLock = null;
      _currentStep = 0;
      _pinController.clear();
      _confirmPinController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _patternPoints.clear();
      _confirmPatternPoints.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("App lock removed.")));
  }

  void _clearPattern() {
    setState(() {
      _patternPoints.clear();
    });
  }

  void _clearConfirmPattern() {
    setState(() {
      _confirmPatternPoints.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "App Lock",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black.withOpacity(0.9),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black87,
                ),
                onPressed: _goBack,
              )
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black87,
                ),
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
          padding: const EdgeInsets.all(24),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return LockTypeSelectionWidget(
          currentLock: currentLock,
          onLockTypeSelected: _selectLockType,
          onRemoveLock: _removeLock,
        );
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
          onSaveLock: _saveLock,
          validateStep: _validateStep2,
        );
      default:
        return LockTypeSelectionWidget(
          currentLock: currentLock,
          onLockTypeSelected: _selectLockType,
          onRemoveLock: _removeLock,
        );
    }
  }
}