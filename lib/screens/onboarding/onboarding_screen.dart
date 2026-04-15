import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import 'package:jeevanpatra/config/app_constants.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  static const _primary = Color(0xFF1A73E8);
  static const _secondary = Color(0xFF00BFA5);

  static const _features = [
    _Feature(
      icon: Iconsax.document_text,
      title: 'Digital Health Records',
      description: 'Securely store and access your medical records',
      color: Color(0xFF1A73E8),
    ),
    _Feature(
      icon: Iconsax.calendar_tick,
      title: 'Book Appointments',
      description: 'Find and book doctors near you instantly',
      color: Color(0xFF00BFA5),
    ),
    _Feature(
      icon: Iconsax.receipt_item,
      title: 'E-Prescriptions',
      description: 'Receive and manage prescriptions digitally',
      color: Color(0xFF7C4DFF),
    ),
    _Feature(
      icon: Iconsax.people,
      title: 'Connected Healthcare',
      description:
          'Seamless communication between patients, doctors & pharmacists',
      color: Color(0xFFFF6D00),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F9FF),
              Colors.white,
              Color(0xFFF0FDFA),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // --- Hero section ---
                      Image.asset(
                        'assets/logo.png',
                        width: size.width * 0.2,
                        height: size.width * 0.2,
                      )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            duration: 500.ms,
                            curve: Curves.easeOut,
                          ),

                      const SizedBox(height: 16),

                      Text(
                        AppConstants.appName,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                      const SizedBox(height: 4),

                      Text(
                        AppConstants.appSlogan,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                      const SizedBox(height: 40),

                      // --- Feature cards ---
                      ...List.generate(_features.length, (i) {
                        final feature = _features[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _FeatureCard(feature: feature),
                        )
                            .animate()
                            .fadeIn(
                              delay: (500 + i * 150).ms,
                              duration: 400.ms,
                            )
                            .slideX(
                              begin: 0.15,
                              end: 0,
                              delay: (500 + i * 150).ms,
                              duration: 400.ms,
                              curve: Curves.easeOut,
                            );
                      }),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // --- Sticky Get Started button ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: _GetStartedButton(
                  onPressed: () => context.go('/login'),
                ),
              )
                  .animate()
                  .fadeIn(delay: 1100.ms, duration: 500.ms)
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    delay: 1100.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Feature data model ---
class _Feature {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

// --- Feature card widget ---
class _FeatureCard extends StatelessWidget {
  final _Feature feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: feature.color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: feature.color.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: feature.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(feature.icon, color: feature.color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Get Started button with press animation ---
class _GetStartedButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _GetStartedButton({required this.onPressed});

  @override
  State<_GetStartedButton> createState() => _GetStartedButtonState();
}

class _GetStartedButtonState extends State<_GetStartedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressController.forward();
  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
    widget.onPressed();
  }

  void _onTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [
                OnboardingScreen._primary,
                OnboardingScreen._secondary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: OnboardingScreen._primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get Started',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
