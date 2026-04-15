import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import 'package:jeevanpatra/config/app_constants.dart';
import 'package:jeevanpatra/models/user_model.dart';
import 'package:jeevanpatra/providers/auth_provider.dart';
import 'package:jeevanpatra/utils/validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  static const _primary = Color(0xFF1A73E8);
  static const _secondary = Color(0xFF00BFA5);

  final _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1 – Basic Info
  final _step1Key = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Step 2 – Account Type
  UserType _selectedType = UserType.patient;

  // Step 3 – Password
  final _step3Key = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Step 4 – Aadhar
  final _step4Key = GlobalKey<FormState>();
  final _aadharCtrl = TextEditingController();

  static const _totalSteps = 4;

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _aadharCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    } else {
      context.go('/login');
    }
  }

  // ── Password strength helpers ──

  double get _passwordStrength {
    final p = _passwordCtrl.text;
    if (p.isEmpty) return 0;
    double s = 0;
    if (p.length >= 8) s += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(p)) s += 0.2;
    if (RegExp(r'[a-z]').hasMatch(p)) s += 0.2;
    if (RegExp(r'[0-9]').hasMatch(p)) s += 0.2;
    if (RegExp(r'[!@#\$%\^&\*]').hasMatch(p)) s += 0.2;
    return s;
  }

  Color get _strengthColor {
    final s = _passwordStrength;
    if (s <= 0.4) return Colors.red;
    if (s <= 0.6) return Colors.orange;
    return _secondary;
  }

  String get _strengthLabel {
    final s = _passwordStrength;
    if (s <= 0.4) return 'Weak';
    if (s <= 0.6) return 'Medium';
    return 'Strong';
  }

  bool _passCheck(String pattern) =>
      RegExp(pattern).hasMatch(_passwordCtrl.text);

  // ── Submit ──

  Future<void> _handleSubmit() async {
    if (!_step4Key.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final error = await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          fullName: _nameCtrl.text.trim(),
          mobileNumber: _mobileCtrl.text.trim(),
          userType: _selectedType,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final generatedId =
        'JP${(Random().nextInt(90000000) + 10000000).toString()}';

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Iconsax.tick_circle, color: _secondary, size: 56),
            const SizedBox(height: 12),
            Text(
              'Account Created!',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your unique User ID:',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                generatedId,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please save this ID for future reference.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/login');
              },
              child: Text('Go to Login',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F6FF), Colors.white, Color(0xFFF0FFF4)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStepIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                    _buildStep4(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: _prevPage,
            icon: const Icon(Iconsax.arrow_left_2),
          ),
          Expanded(
            child: Text(
              'Create Account',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 48), // balance
        ],
      ),
    );
  }

  // ── Step Indicator ──

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Column(
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              minHeight: 4,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(_primary),
            ),
          ),
          const SizedBox(height: 10),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalSteps, (i) {
              final isActive = i <= _currentStep;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 10 : 8,
                height: isActive ? 10 : 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? _primary : Colors.grey.shade300,
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            'Step ${_currentStep + 1} of $_totalSteps',
            style:
                GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Basic Info ──

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Basic Information',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ).animate().fadeIn().slideY(begin: 0.2),
            const SizedBox(height: 4),
            Text(
              'Tell us about yourself',
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.grey.shade600),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 28),

            TextFormField(
              controller: _nameCtrl,
              validator: Validators.validateName,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: _inputDecoration(
                  label: 'Full Name', icon: Iconsax.user),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05),

            const SizedBox(height: 16),

            TextFormField(
              controller: _mobileCtrl,
              validator: Validators.validateMobile,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: _inputDecoration(
                label: 'Mobile Number',
                icon: Iconsax.call,
              ).copyWith(
                prefixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 14),
                    Text(
                      AppConstants.countryCode,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                        width: 1, height: 24, color: Colors.grey.shade300),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.05),

            const SizedBox(height: 16),

            TextFormField(
              controller: _emailCtrl,
              validator: Validators.validateEmail,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: _inputDecoration(
                  label: 'Email Address', icon: Iconsax.sms),
            ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.05),

            const SizedBox(height: 32),

            _nextButton(onPressed: () {
              if (_step1Key.currentState!.validate()) _nextPage();
            }).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Account Type ──

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Account Type',
            style:
                GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
          ).animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 4),
          Text(
            'Choose how you want to use ${AppConstants.appName}',
            style:
                GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 28),

          _typeCard(
            type: UserType.patient,
            icon: Iconsax.heart,
            title: 'Patient',
            subtitle: 'Manage your health records',
            color: const Color(0xFFE91E63),
            delay: 200,
          ),
          const SizedBox(height: 14),
          _typeCard(
            type: UserType.doctor,
            icon: Iconsax.briefcase,
            title: 'Doctor',
            subtitle: 'Manage patients & consultations',
            color: _primary,
            delay: 300,
          ),
          const SizedBox(height: 14),
          _typeCard(
            type: UserType.pharmacist,
            icon: Iconsax.mask,
            title: 'Pharmacist',
            subtitle: 'Manage inventory & prescriptions',
            color: _secondary,
            delay: 400,
          ),

          const SizedBox(height: 32),

          _nextButton(onPressed: _nextPage)
              .animate()
              .fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _typeCard({
    required UserType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int delay,
  }) {
    final selected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.07) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(
              selected ? Iconsax.tick_circle5 : Iconsax.record,
              color: selected ? color : Colors.grey.shade300,
              size: 24,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: -0.05);
  }

  // ── Step 3: Password ──

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Form(
        key: _step3Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Create Password',
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.bold))
                .animate()
                .fadeIn()
                .slideY(begin: 0.2),
            const SizedBox(height: 4),
            Text('Choose a strong password',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey.shade600))
                .animate()
                .fadeIn(delay: 100.ms),
            const SizedBox(height: 28),

            // Password
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              validator: Validators.validatePassword,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: _inputDecoration(
                label: 'Password',
                icon: Iconsax.lock,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 12),

            // Strength bar
            if (_passwordCtrl.text.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _passwordStrength,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_strengthColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _strengthLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _strengthColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Requirements
              _checkRow('At least 8 characters', _passwordCtrl.text.length >= 8),
              _checkRow('An uppercase letter', _passCheck(r'[A-Z]')),
              _checkRow('A lowercase letter', _passCheck(r'[a-z]')),
              _checkRow('A digit', _passCheck(r'[0-9]')),
              _checkRow(r'A special character (!@#$%^&*)', _passCheck(r'[!@#\$%\^&\*]')),
            ],

            const SizedBox(height: 20),

            // Confirm Password
            TextFormField(
              controller: _confirmPasswordCtrl,
              obscureText: _obscureConfirm,
              validator: (v) =>
                  Validators.validateConfirmPassword(v, _passwordCtrl.text),
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: _inputDecoration(
                label: 'Confirm Password',
                icon: Iconsax.lock_1,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Iconsax.eye_slash : Iconsax.eye,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 32),

            _nextButton(onPressed: () {
              if (_step3Key.currentState!.validate()) _nextPage();
            }).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _checkRow(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            met ? Iconsax.tick_circle5 : Iconsax.close_circle,
            size: 18,
            color: met ? _secondary : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: met ? _secondary : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 4: Aadhar ──

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Form(
        key: _step4Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Aadhar Verification',
                    style: GoogleFonts.poppins(
                        fontSize: 22, fontWeight: FontWeight.bold))
                .animate()
                .fadeIn()
                .slideY(begin: 0.2),
            const SizedBox(height: 4),
            Text('Link your Aadhar for identity verification',
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey.shade600))
                .animate()
                .fadeIn(delay: 100.ms),
            const SizedBox(height: 32),

            // Security visual
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.shield_tick, size: 40, color: _primary),
              )
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
            ),

            const SizedBox(height: 28),

            TextFormField(
              controller: _aadharCtrl,
              validator: Validators.validateAadhar,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
                _AadharFormatter(),
              ],
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 2),
              decoration: _inputDecoration(
                label: 'Aadhar Number',
                icon: Iconsax.card,
              ).copyWith(hintText: 'XXXX XXXX XXXX'),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _secondary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _secondary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.lock, color: _secondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your Aadhar is encrypted with AES-256 encryption',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: _secondary),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 32),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Submit',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  // ── Shared widgets ──

  Widget _nextButton({required VoidCallback onPressed}) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          'Next',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
      prefixIcon:
          Icon(icon, size: 20, color: _primary.withValues(alpha: 0.7)),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
    );
  }
}

/// Formats Aadhar digits as XXXX XXXX XXXX.
class _AadharFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
