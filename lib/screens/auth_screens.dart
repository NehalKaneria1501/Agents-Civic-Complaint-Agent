import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/civic_colors.dart';
import '../widgets/civic_app_logo.dart';

// ==========================================
// SCREEN: CITIZEN SIGN IN SCREEN
// ==========================================

class SignInScreen extends StatefulWidget {
  final VoidCallback onSignInSuccess;
  final VoidCallback onForgotPassword;
  final Function(String phone) onSignInWithOtp;
  final VoidCallback onGuestDemo;

  const SignInScreen({
    super.key,
    required this.onSignInSuccess,
    required this.onForgotPassword,
    required this.onSignInWithOtp,
    required this.onGuestDemo,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phoneOrEmailCtrl = TextEditingController(text: '+91 98765 43210');
  final _passwordCtrl = TextEditingController(text: 'Ahmedabad@2026');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  int _roleIndex = 0; // 0 = Citizen, 1 = AMC Field Staff

  @override
  void dispose() {
    _phoneOrEmailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivicColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Brand Row
              Row(
                children: [
                  const CivicAppLogo(
                    size: 36,
                    showShadow: false,
                  ),
                  const SizedBox(width: 10),
                  const Text('CivicAgent Portal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CivicColors.primary)),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Welcome Back', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: CivicColors.onSurface, letterSpacing: -0.5)),
              const SizedBox(height: 6),
              const Text('Sign in to track filed municipal complaints, inspect live squad dispatch, and verify resolutions.', style: TextStyle(fontSize: 13, color: CivicColors.onSurfaceVariant, height: 1.4)),

              const SizedBox(height: 22),

              // Role Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: CivicColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _roleIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _roleIndex == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _roleIndex == 0 ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                          ),
                          child: Center(
                            child: Text(
                              'Citizen Login',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: _roleIndex == 0 ? CivicColors.primary : CivicColors.onSurfaceVariant),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _roleIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _roleIndex == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _roleIndex == 1 ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                          ),
                          child: Center(
                            child: Text(
                              'AMC Field Officer',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: _roleIndex == 1 ? CivicColors.primary : CivicColors.onSurfaceVariant),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Input: Phone or Email
              TextField(
                controller: _phoneOrEmailCtrl,
                decoration: InputDecoration(
                  labelText: 'Mobile Number or Email',
                  prefixIcon: const Icon(Icons.phone_android_rounded, color: CivicColors.primary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3))),
                ),
              ),
              const SizedBox(height: 14),

              // Input: Password
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: CivicColors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3))),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: CivicColors.primary,
                        onChanged: (v) => setState(() => _rememberMe = v ?? true),
                      ),
                      const Text('Remember me', style: TextStyle(fontSize: 12.5, color: CivicColors.onSurfaceVariant)),
                    ],
                  ),
                  TextButton(
                    onPressed: widget.onForgotPassword,
                    child: const Text('Forgot Password?', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: CivicColors.primary)),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sign In Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: widget.onSignInSuccess,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CivicColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 12),

              // Sign In with OTP
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => widget.onSignInWithOtp(_phoneOrEmailCtrl.text),
                  icon: const Icon(Icons.sms_outlined, size: 18),
                  label: const Text('Sign In with OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CivicColors.primary,
                    side: const BorderSide(color: CivicColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Sign in with Google Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    // Sign in with Google flow
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Signed in with Google Account successfully!'),
                          ],
                        ),
                        backgroundColor: Color(0xFF1E8E3E),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    widget.onSignInSuccess();
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGoogleIcon(),
                      const SizedBox(width: 10),
                      const Text(
                        'Sign in with Google',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1F1F1F)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Center(
                child: TextButton(
                  onPressed: widget.onGuestDemo,
                  child: const Text('Continue as Guest Citizen (Instant Demo)', style: TextStyle(fontSize: 13, color: CivicColors.onSurfaceVariant)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            fontFamily: 'Roboto',
            color: const Color(0xFF4285F4),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// SCREEN: FORGOT PASSWORD SCREEN
// ==========================================

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(String phone) onSendOtp;

  const ForgotPasswordScreen({
    super.key,
    required this.onBack,
    required this.onSendOtp,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailPhoneCtrl = TextEditingController(text: '+91 98765 43210');

  @override
  void dispose() {
    _emailPhoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivicColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: CivicColors.onSurface),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CivicColors.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.lock_reset_rounded, color: CivicColors.primary, size: 32),
              ),
              const SizedBox(height: 20),
              const Text('Reset Citizen Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: CivicColors.onSurface, letterSpacing: -0.5)),
              const SizedBox(height: 6),
              const Text('Enter your registered Mobile Number or Citizen Email. We will send you a 6-digit verification code to reset your account credentials.', style: TextStyle(fontSize: 13, color: CivicColors.onSurfaceVariant, height: 1.4)),

              const SizedBox(height: 24),

              TextField(
                controller: _emailPhoneCtrl,
                decoration: InputDecoration(
                  labelText: 'Registered Mobile or Email',
                  prefixIcon: const Icon(Icons.contact_mail_outlined, color: CivicColors.primary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3))),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => widget.onSendOtp(_emailPhoneCtrl.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CivicColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Send Verification OTP', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// SCREEN: OTP VERIFICATION SCREEN
// ==========================================

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isResetPassword;
  final VoidCallback onBack;
  final VoidCallback onVerificationSuccess;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.isResetPassword,
    required this.onBack,
    required this.onVerificationSuccess,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _fillDemoOtp() {
    const code = '428915';
    for (int i = 0; i < 6; i++) {
      _controllers[i].text = code[i];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivicColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: CivicColors.onSurface),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CivicColors.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.mark_email_read_rounded, color: CivicColors.secondary, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                widget.isResetPassword ? 'Reset Password OTP' : 'OTP Verification',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: CivicColors.onSurface, letterSpacing: -0.5),
              ),
              const SizedBox(height: 6),
              Text(
                'We have sent a 6-digit one-time password to ${widget.phoneNumber}. Please enter it below.',
                style: const TextStyle(fontSize: 13, color: CivicColors.onSurfaceVariant, height: 1.4),
              ),

              const SizedBox(height: 28),

              // 6 OTP Box Fields (Responsive and auto-scaled to prevent render overflows)
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 46,
                        height: 54,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: CivicColors.primary, width: 2),
                            ),
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (val.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _fillDemoOtp,
                    icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
                    label: const Text('Auto-fill (428915)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  Text(
                    _secondsRemaining > 0 ? 'Resend in 00:${_secondsRemaining.toString().padLeft(2, '0')}' : 'Expired',
                    style: TextStyle(fontSize: 12, color: _secondsRemaining > 0 ? CivicColors.onSurfaceVariant : CivicColors.error),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ OTP Verified! Authenticated with Ahmedabad Municipal Corporation.'),
                        backgroundColor: CivicColors.secondary,
                      ),
                    );
                    widget.onVerificationSuccess();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CivicColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Verify & Proceed', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
