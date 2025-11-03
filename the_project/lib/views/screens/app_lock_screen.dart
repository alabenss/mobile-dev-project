import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../themes/style_simple/colors.dart';

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lock values don't match!")));
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("App lock removed.")));
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
        return _buildLockTypeSelection();
      case 1:
        return _buildSetLockStep();
      case 2:
        return _buildConfirmLockStep();
      default:
        return _buildLockTypeSelection();
    }
  }

  Widget _buildLockTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Choose Lock Type:",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),

        // Lock Type Cards
        _buildLockTypeCard(
          title: "PIN",
          subtitle: "Secure with numeric PIN",
          icon: Icons.pin_outlined,
          type: "pin",
        ),
        const SizedBox(height: 16),
        _buildLockTypeCard(
          title: "Pattern",
          subtitle: "Draw a pattern to unlock",
          icon: Icons.gesture_outlined,
          type: "pattern",
        ),
        const SizedBox(height: 16),
        _buildLockTypeCard(
          title: "Password",
          subtitle: "Use alphanumeric password",
          icon: Icons.password_outlined,
          type: "password",
        ),

        const Spacer(),

        // Remove Lock Button if exists
        if (currentLock != null) ...[
          ElevatedButton.icon(
            onPressed: _removeLock,
            icon: const Icon(Icons.lock_open),
            label: const Text("Remove Existing Lock"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildLockTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String type,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, size: 32, color: AppColors.accentPink),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _selectLockType(type),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildSetLockStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Set Your ${selectedLockType?.toUpperCase()}",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Create your ${selectedLockType} lock",
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),

        if (selectedLockType == "pin") ...[
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: "Enter 4-6 digit PIN",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              counterText: "",
            ),
            onChanged: (value) => setState(() {}),
          ),
        ] else if (selectedLockType == "pattern") ...[
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                PatternLock(
                  points: _patternPoints,
                  onPatternDraw: (points) {
                    setState(() {
                      _patternPoints = points;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  _patternPoints.isEmpty
                      ? "Draw your pattern"
                      : "Points selected: ${_patternPoints.length}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_patternPoints.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _patternPoints.clear();
                      });
                    },
                    child: Text(
                      "Redraw Pattern",
                      style: GoogleFonts.poppins(color: AppColors.accentPink),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ] else if (selectedLockType == "password") ...[
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Enter password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ],

        const Spacer(),

        ElevatedButton(
          onPressed: _validateStep1()
              ? () => setState(() => _currentStep = 2)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentPink,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text("Continue"),
        ),
      ],
    );
  }

  Widget _buildConfirmLockStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Confirm Your ${selectedLockType?.toUpperCase()}",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Re-enter your ${selectedLockType} to confirm",
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),

        if (selectedLockType == "pin") ...[
          TextField(
            controller: _confirmPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: "Confirm your PIN",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
              counterText: "",
            ),
            onChanged: (value) => setState(() {}),
          ),
        ] else if (selectedLockType == "pattern") ...[
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                PatternLock(
                  points: _confirmPatternPoints,
                  onPatternDraw: (points) {
                    setState(() {
                      _confirmPatternPoints = points;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  _confirmPatternPoints.isEmpty
                      ? "Draw your pattern again"
                      : "Points selected: ${_confirmPatternPoints.length}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_confirmPatternPoints.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _confirmPatternPoints.clear();
                      });
                    },
                    child: Text(
                      "Redraw Pattern",
                      style: GoogleFonts.poppins(color: AppColors.accentPink),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ] else if (selectedLockType == "password") ...[
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Confirm your password",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.9),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ],

        const Spacer(),

        if (!_validateStep2()) ...[
          Text(
            "Lock values don't match!",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
          ),
          const SizedBox(height: 8),
        ],

        ElevatedButton(
          onPressed: _validateStep2() ? _saveLock : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentPink,
            foregroundColor: Colors.white,
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

class PatternLock extends StatefulWidget {
  final List<int> points;
  final Function(List<int>) onPatternDraw;

  const PatternLock({
    super.key,
    required this.points,
    required this.onPatternDraw,
  });

  @override
  State<PatternLock> createState() => _PatternLockState();
}

class _PatternLockState extends State<PatternLock> {
  List<Offset> dotPositions = [];
  List<Offset> linePoints = [];

  @override
  void initState() {
    super.initState();
    _calculateDotPositions();
  }

  void _calculateDotPositions() {
    dotPositions.clear();
    const double spacing = 70.0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        dotPositions.add(Offset(j * spacing, i * spacing));
      }
    }
  }

  int _getNearestDot(Offset position) {
    for (int i = 0; i < dotPositions.length; i++) {
      if ((position - dotPositions[i]).distance < 30) {
        return i;
      }
    }
    return -1;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    int nearestDot = _getNearestDot(localPosition);
    if (nearestDot != -1 && !widget.points.contains(nearestDot)) {
      List<int> newPoints = List.from(widget.points)..add(nearestDot);
      widget.onPatternDraw(newPoints);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    // Pattern drawing completed
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        width: 210,
        height: 210,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: CustomPaint(
          painter: PatternPainter(
            points: widget.points,
            dotPositions: dotPositions,
          ),
        ),
      ),
    );
  }
}

class PatternPainter extends CustomPainter {
  final List<int> points;
  final List<Offset> dotPositions;

  PatternPainter({required this.points, required this.dotPositions});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;

    final selectedDotPaint = Paint()
      ..color = AppColors.accentPink
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.accentPink
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Draw lines between selected points
    if (points.length > 1) {
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(
          dotPositions[points[i]],
          dotPositions[points[i + 1]],
          linePaint,
        );
      }
    }

    // Draw dots
    for (int i = 0; i < dotPositions.length; i++) {
      canvas.drawCircle(
        dotPositions[i],
        points.contains(i) ? 12 : 8,
        points.contains(i) ? selectedDotPaint : dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
