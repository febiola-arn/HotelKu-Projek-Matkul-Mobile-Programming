import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    // Fade and scale animation
    _fadeController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    // Pulsing animation for logo
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Wave animation
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );

    _fadeController.forward();

    // Navigate based on auth state
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for animation
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Initialize Auth
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();

    if (!mounted) return;

    // Fade out animation
    await _fadeController.reverse();
    
    if (!mounted) return;

    // Stop animations
    _pulseController.stop();
    _waveController.stop();

    // Route based on role
    if (authProvider.isLoggedIn && authProvider.isAdmin) {
      Navigator.of(context).pushReplacementNamed('/admin_dashboard');
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.oceanGradient +
                    [AppColors.sunsetGradient.last],
                stops: [
                  0.0,
                  0.5 + (_waveAnimation.value * 0.2),
                  1.0,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Wave effect overlay
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.3,
                    child: CustomPaint(
                      painter: WavePainter(_waveAnimation.value),
                    ),
                  ),
                ),
                
                // Main content
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Pulsing Logo
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.xxl),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentColor.withOpacity(0.4),
                                    blurRadius: 40,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: AppColors.sunsetGradient,
                                ).createShader(bounds),
                                child: const Icon(
                                  Icons.beach_access,
                                  size: 100,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: AppSpacing.xxl),
                          
                          // App Name
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                AppColors.white,
                                Color(0xFFFFF8E1),
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'HotelKu',
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          // Island Paradise Tagline
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
                              border: Border.all(
                                color: AppColors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              '🏝️ Your Gateway to Paradise',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppColors.white,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: AppSpacing.xxl),
                          
                          // Loading indicator
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                              strokeWidth: 4,
                              backgroundColor: AppColors.white.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Custom painter for wave effect
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Create wave effect
    path.moveTo(0, size.height * 0.7);
    
    for (double i = 0; i < size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.7 +
            20 * math.sin((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)),
      );
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
