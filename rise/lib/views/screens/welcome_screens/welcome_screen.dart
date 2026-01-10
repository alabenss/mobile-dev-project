// lib/screens/welcome_screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'welcome_page.dart';
import 'welcome_provider.dart';
import '../../themes/style_simple/colors.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const WelcomeScreen({super.key, required this.onCompleted});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;

  final List<WelcomePage> _pages = [
    const WelcomePage(
      title: "Welcome to Rise",
      description:
          "Your personal companion for mental wellness and daily balance in a stressful, screen-dominated world.",
      imageAsset: 'assets/images/logo_rise.png',
      isFirstPage: true,
      gradientColors: [
        AppColors.bgTop,
        AppColors.bgMid,
        AppColors.bgBottom,
      ],
    ),
    WelcomePage(
      title: "Balance & Focus",
      description:
          "Merge productivity with peace. Build healthy habits while reducing digital fatigue through guided breaks.",
      iconData: Icons.balance,
      gradientColors: [
        AppColors.bgTop.withOpacity(0.9),
        AppColors.bgMid.withOpacity(0.9),
        AppColors.bgBottom.withOpacity(0.9),
      ],
    ),
    WelcomePage(
      title: "Emotional Awareness",
      description:
          "Track your mood, reflect on emotions, and engage with mindfulness activities for your well-being.",
      iconData: Icons.emoji_emotions,
      gradientColors: const [
        AppColors.bgTop,
        AppColors.bgMid,
        AppColors.bgBottom,
      ],
    ),
    WelcomePage(
      title: "Gamified Growth",
      description:
          "Earn rewards for consistency. Build lasting healthy habits with emotional awareness and motivation.",
      iconData: Icons.emoji_events,
      gradientColors: [
        AppColors.bgTop.withOpacity(0.9),
        AppColors.bgMid.withOpacity(0.9),
        AppColors.bgBottom.withOpacity(0.9),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonAnimation = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    );
    _buttonController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void _completeWelcome() async {
    await WelcomeProvider.markWelcomeSeen();
    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _buttonController.reset();
                _buttonController.forward();
              });
            },
            itemBuilder: (context, index) {
              return _pages[index];
            },
          ),

          Positioned(
            left: 15,
            right: 15,
            bottom: 30,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_currentPage < _pages.length - 1)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _completeWelcome,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "Skip",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 8),

                    const SizedBox(height: 4),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: _pages.length,
                          effect: ExpandingDotsEffect(
                            activeDotColor: AppColors.peach,
                            dotColor: AppColors.peach.withOpacity(0.3),
                            dotHeight: 9,
                            dotWidth: 9,
                            spacing: 6,
                            expansionFactor: 3,
                          ),
                        ),

                        ScaleTransition(
                          scale: _buttonAnimation,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentPage < _pages.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                _completeWelcome();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.peach,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 11,
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentPage == _pages.length - 1
                                      ? "Get Started"
                                      : "Next",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  _currentPage == _pages.length - 1
                                      ? Icons.check_circle_outline
                                      : Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}