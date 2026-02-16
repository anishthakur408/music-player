import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/glass_card.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _startAnimations();

    // Navigate to main screen after delay
    _navigateToMainScreen();
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 300));
    _scaleController.forward();

    await Future.delayed(Duration(milliseconds: 200));
    _fadeController.forward();

    await Future.delayed(Duration(milliseconds: 300));
    _slideController.forward();
  }

  void _navigateToMainScreen() async {
    await Future.delayed(Duration(seconds: 3));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main logo animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: GlassCard(
                      width: 140,
                      height: 140,
                      padding: EdgeInsets.all(30),
                      borderRadius: 35,
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 70,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40),

                // App name animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'vNyl',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),

                        SizedBox(height: 12),

                        Text(
                          'Your Music Companion',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 60),

                // Loading indicator
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _LoadingIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatefulWidget {
  @override
  __LoadingIndicatorState createState() => __LoadingIndicatorState();
}

class __LoadingIndicatorState extends State<_LoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pulsing dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    child: Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.7),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),

        SizedBox(height: 20),

        // Loading text
        Text(
          '',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// Alternative splash screen with music wave animation
class WaveSplashScreen extends StatefulWidget {
  @override
  _WaveSplashScreenState createState() => _WaveSplashScreenState();
}

class _WaveSplashScreenState extends State<WaveSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late List<Animation<double>> _waveAnimations;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    // Create staggered wave animations
    _waveAnimations = List.generate(5, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _waveController,
          curve: Interval(
            index * 0.1,
            0.5 + index * 0.1,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    _waveController.repeat(reverse: true);

    // Navigate after delay
    Timer(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              GlassCard(
                width: 120,
                height: 120,
                padding: EdgeInsets.all(25),
                borderRadius: 30,
                child: Icon(
                  Icons.multitrack_audio_outlined,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),

              SizedBox(height: 40),

              Text(
                '',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 40),

              // Animated wave bars
              Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _waveAnimations.asMap().entries.map((entry) {
                    int index = entry.key;
                    Animation<double> animation = entry.value;

                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return Container(
                          width: 6,
                          height: 20 + (animation.value * 40),
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}