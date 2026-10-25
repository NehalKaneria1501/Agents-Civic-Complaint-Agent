import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/civic_colors.dart';
import '../widgets/civic_app_logo.dart';

// ==========================================
// SCREEN 0: CIVIC SPLASH SCREEN
// Responsive, Overflow-Proof & High-Impact Emblem
// ==========================================

class SplashScreen extends StatefulWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onSkipToMain;

  const SplashScreen({
    super.key,
    required this.onGetStarted,
    required this.onSkipToMain,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = math.min(screenWidth * 0.42, 155.0).clamp(120.0, 160.0);

    return Scaffold(
      backgroundColor: CivicColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        // Animated Pulsing App Icon Halo with Enlarged Hero Image
                        AnimatedBuilder(
                          animation: _animCtrl,
                          builder: (context, child) {
                            return Container(
                              padding: EdgeInsets.all(14 + (_animCtrl.value * 8)),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CivicColors.primaryContainer.withValues(alpha: 0.18 + (_animCtrl.value * 0.16)),
                                boxShadow: [
                                  BoxShadow(
                                    color: CivicColors.primary.withValues(alpha: 0.15 + (_animCtrl.value * 0.12)),
                                    blurRadius: 36,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: CivicAppLogo(
                              size: logoSize,
                              showShadow: false,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'CivicAgent',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: CivicColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Ahmedabad Municipal Corporation',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: CivicColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'AI Issue Detection • Ward Routing • Instant Ticket Dispatch',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: CivicColors.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Status Loading Indicator Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: CivicColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: CivicColors.primary,
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  'Connected to AMC Civic Mesh (Ward 4 GIS)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: CivicColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 20),

                        // Action Buttons
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: widget.onGetStarted,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CivicColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Get Started', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: widget.onSkipToMain,
                          child: const Text(
                            'Launch Instant Demo (Skip Login)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: CivicColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
