// lib/screens/welcome_screens/welcome_page.dart
import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';

class WelcomePage extends StatefulWidget {
  final String title;
  final String description;
  final String imageAsset;
  final IconData? iconData;
  final List<Color>? gradientColors;
  final bool isFirstPage;
  final bool isLogoOnlyPage;

  const WelcomePage({
    super.key,
    required this.title,
    required this.description,
    this.imageAsset = '',
    this.iconData,
    this.gradientColors,
    this.isFirstPage = false,
    this.isLogoOnlyPage = false,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Special logo-only page with solid yellow background
    if (widget.isLogoOnlyPage) {
      return Container(
        color: AppColors.yellow,
        child: SafeArea(
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  widget.imageAsset,
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.self_improvement,
                      size: 120,
                      color: AppColors.peach,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Regular pages with gradient (FIX 1: scrollable + proper bottom padding)
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: widget.gradientColors ??
              [
                AppColors.bgTop,
                AppColors.bgMid,
                AppColors.bgBottom,
              ],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Reserve space so the floating bottom bar doesn't overlap content.
            // Adjust if you change the bottom bar height.
            const double bottomBarSpace = 160;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: bottomBarSpace),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Image / Logo area (adaptive height)
                      SizedBox(
                        height: constraints.maxHeight * 0.45,
                        child: _buildAnimatedImageSection(),
                      ),

                      const SizedBox(height: 20),

                      // Content (can grow; will scroll if needed)
                      _buildAnimatedContentSection(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedImageSection() {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: widget.isFirstPage && widget.imageAsset.isNotEmpty
              ? _buildRectangularLogo()
              : _buildCircularIcon(),
        ),
      ),
    );
  }

  // Rectangular logo container - NO SHADOW
  Widget _buildRectangularLogo() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Image.asset(
              widget.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.self_improvement,
                  size: 100,
                  color: AppColors.peach,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Circular icon container - NO SHADOW
  Widget _buildCircularIcon() {
    return Container(
      width: 250,
      height: 250,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.95),
          ),
          child: Center(
            child: _buildImage(),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (widget.iconData != null) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Icon(
              widget.iconData,
              size: 100,
              color: AppColors.peach,
            ),
          );
        },
      );
    }
    return Icon(
      Icons.self_improvement,
      size: 100,
      color: AppColors.peach,
    );
  }

  Widget _buildAnimatedContentSection() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: widget.isFirstPage ? 2.0 : 1.2,
                  fontFamily: 'Pacifico',
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              Text(
                widget.description,
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.textSecondary,
                  height: 1.6,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'JosefinSans',
                  shadows: const [
                    Shadow(
                      color: Colors.black12,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
