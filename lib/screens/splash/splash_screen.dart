import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jeevanpatra/config/app_constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _glowController;
  bool _showLoader = false;

  static const _primary = Color(0xFF1A73E8);
  static const _secondary = Color(0xFF00BFA5);

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Show loader after logo animation completes (~1.2s)
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _showLoader = true);
    });

    // Navigate after all animations finish (~3s)
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFE0F7FA),
              Color(0xFFB2EBF2),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // --- Pulsing glow + logo ---
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  final glowOpacity = 0.15 + _glowController.value * 0.2;
                  final glowRadius = 30.0 + _glowController.value * 20.0;
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withValues(alpha: glowOpacity),
                          blurRadius: glowRadius,
                          spreadRadius: glowRadius * 0.4,
                        ),
                        BoxShadow(
                          color: _secondary.withValues(alpha: glowOpacity * 0.6),
                          blurRadius: glowRadius * 0.8,
                          spreadRadius: glowRadius * 0.2,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/logo.png',
                  width: size.width * 0.32,
                  height: size.width * 0.32,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.4, 0.4),
                    end: const Offset(1.0, 1.0),
                    duration: 800.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 600.ms),

              const SizedBox(height: 32),

              // --- App name: letter-by-letter fade ---
              Row(
                mainAxisSize: MainAxisSize.min,
                children: AppConstants.appName
                    .split('')
                    .asMap()
                    .entries
                    .map((entry) {
                  return Text(
                    entry.value,
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                      letterSpacing: 1.5,
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: (600 + entry.key * 80).ms,
                        duration: 300.ms,
                      )
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        delay: (600 + entry.key * 80).ms,
                        duration: 300.ms,
                        curve: Curves.easeOut,
                      );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // --- Slogan: slide-up + fade ---
              Text(
                AppConstants.appSlogan,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: _secondary,
                  letterSpacing: 0.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: 1800.ms, duration: 600.ms)
                  .slideY(
                    begin: 0.5,
                    end: 0,
                    delay: 1800.ms,
                    duration: 600.ms,
                    curve: Curves.easeOut,
                  ),

              const Spacer(flex: 3),

              // --- Loading indicator ---
              AnimatedOpacity(
                opacity: _showLoader ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _primary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
