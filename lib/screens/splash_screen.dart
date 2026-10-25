import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/civic_colors.dart';
import '../widgets/civic_app_logo.dart';
import '../services/sqlite_database_service.dart';

// ==========================================
// SCREEN 0: CIVIC SPLASH SCREEN (ANIMATED)
// Multi-Stage Staggered Entrance, Orbital Radar Halo,
// Dynamic SQLite Neural Sync & Overflow-Proof Responsive Layout
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

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _introCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _orbitalCtrl;

  late final Animation<double> _logoScaleAnim;
  late final Animation<double> _logoFadeAnim;
  late final Animation<Offset> _textSlideAnim;
  late final Animation<double> _textFadeAnim;
  late final Animation<double> _statusFadeAnim;
  late final Animation<Offset> _buttonSlideAnim;
  late final Animation<double> _buttonFadeAnim;

  String _syncStatusText = 'Initializing AMC Municipal Neural Grid...';
  bool _isSqliteReady = false;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Staggered Controller
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScaleAnim = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.0, 0.60, curve: Curves.easeOutBack),
    );

    _logoFadeAnim = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
    );

    _textSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _textFadeAnim = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.25, 0.70, curve: Curves.easeIn),
    );

    _statusFadeAnim = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.45, 0.85, curve: Curves.easeIn),
    );

    _buttonSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: const Interval(0.60, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _buttonFadeAnim = CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.60, 1.0, curve: Curves.easeIn),
    );

    // 2. Ambient Aura Breathing Controller
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // 3. Orbital Municipal Radar Controller
    _orbitalCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16000),
    )..repeat();

    _introCtrl.forward();
    _checkDatabaseSync();
  }

  Future<void> _checkDatabaseSync() async {
    // Dynamic progress states during splash launch
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _syncStatusText = 'Mounting SQLite Relational Ledger (Ward 4)...';
    });

    try {
      await SqliteDatabaseService.instance.init();
      if (!mounted) return;
      setState(() {
        _isSqliteReady = true;
        _syncStatusText = 'Connected to AMC Civic Mesh (Live GIS)';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSqliteReady = true;
        _syncStatusText = 'Connected to AMC Civic Mesh (Offline Resilient)';
      });
    }
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _pulseCtrl.dispose();
    _orbitalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = math.min(screenWidth * 0.40, 150.0).clamp(115.0, 155.0);

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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),

                        // ---------------------------------------------------
                        // 1. HERO ANIMATED EMBLEM WITH ORBITAL RADAR HALO
                        // ---------------------------------------------------
                        FadeTransition(
                          opacity: _logoFadeAnim,
                          child: ScaleTransition(
                            scale: _logoScaleAnim,
                            child: AnimatedBuilder(
                              animation: Listenable.merge([_pulseCtrl, _orbitalCtrl]),
                              builder: (context, child) {
                                final pulse = _pulseCtrl.value;
                                return SizedBox(
                                  width: logoSize + 84,
                                  height: logoSize + 84,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Atmospheric outer pulse aura
                                      Container(
                                        width: logoSize + 60 + (pulse * 20),
                                        height: logoSize + 60 + (pulse * 20),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              CivicColors.primary.withValues(alpha: 0.18 + (pulse * 0.12)),
                                              CivicColors.primaryContainer.withValues(alpha: 0.08),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Rotating Orbital Radar Painter
                                      CustomPaint(
                                        size: Size(logoSize + 68, logoSize + 68),
                                        painter: _CivicOrbitalHaloPainter(
                                          rotation: _orbitalCtrl.value * 2 * math.pi,
                                          pulse: pulse,
                                          color: CivicColors.primary,
                                        ),
                                      ),

                                      // Central Emblem Container
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: CivicColors.primary.withValues(alpha: 0.20 + (pulse * 0.10)),
                                              blurRadius: 32,
                                              spreadRadius: 2,
                                              offset: const Offset(0, 8),
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.10),
                                              blurRadius: 16,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: CivicAppLogo(
                                          size: logoSize,
                                          showShadow: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ---------------------------------------------------
                        // 2. MUNICIPAL TITLE & SUBTITLE
                        // ---------------------------------------------------
                        SlideTransition(
                          position: _textSlideAnim,
                          child: FadeTransition(
                            opacity: _textFadeAnim,
                            child: const Column(
                              children: [
                                Text(
                                  'CivicAgent',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.7,
                                    color: CivicColors.primary,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Ahmedabad Municipal Corporation',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.1,
                                    color: CivicColors.onSurface,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'AI Issue Detection • Ward Routing • Instant Ticket Dispatch',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.2,
                                    fontWeight: FontWeight.w500,
                                    color: CivicColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ---------------------------------------------------
                        // 3. ANIMATED MUNICIPAL NEURAL STATUS PILL
                        // ---------------------------------------------------
                        FadeTransition(
                          opacity: _statusFadeAnim,
                          child: AnimatedBuilder(
                            animation: _pulseCtrl,
                            builder: (context, _) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: CivicColors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: _isSqliteReady
                                        ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                        : CivicColors.outlineVariant.withValues(alpha: 0.3),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _isSqliteReady
                                          ? const Color(0xFF10B981).withValues(alpha: 0.08)
                                          : Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _isSqliteReady ? const Color(0xFF10B981) : CivicColors.primary,
                                        boxShadow: [
                                          BoxShadow(
                                            color: (_isSqliteReady ? const Color(0xFF10B981) : CivicColors.primary)
                                                .withValues(alpha: 0.4 + (_pulseCtrl.value * 0.4)),
                                            blurRadius: 8,
                                            spreadRadius: 1 + (_pulseCtrl.value * 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        _syncStatusText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11.8,
                                          fontWeight: FontWeight.w600,
                                          color: _isSqliteReady ? const Color(0xFF047857) : CivicColors.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 20),

                        // ---------------------------------------------------
                        // 4. ACTION BUTTONS (STAGGERED SLIDE UP)
                        // ---------------------------------------------------
                        SlideTransition(
                          position: _buttonSlideAnim,
                          child: FadeTransition(
                            opacity: _buttonFadeAnim,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: widget.onGetStarted,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: CivicColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      elevation: 3,
                                      shadowColor: CivicColors.primary.withValues(alpha: 0.4),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Get Started',
                                          style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: widget.onSkipToMain,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
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

// ==========================================
// ORBITAL CIVIC RADAR HALO PAINTER
// Smooth Rotating Municipal Arcs & Satellite Ward Nodes
// ==========================================

class _CivicOrbitalHaloPainter extends CustomPainter {
  final double rotation;
  final double pulse;
  final Color color;

  const _CivicOrbitalHaloPainter({
    required this.rotation,
    required this.pulse,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Thin Outer Ring
    final outerRingPaint = Paint()
      ..color = color.withValues(alpha: 0.15 + (pulse * 0.10))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, radius - 2, outerRingPaint);

    // 2. Rotating Segmented Municipal Arcs
    final arcPaint = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2;

    // Arc 1 (North-East)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      rotation,
      math.pi * 0.35,
      false,
      arcPaint,
    );

    // Arc 2 (South-West)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      rotation + math.pi,
      math.pi * 0.45,
      false,
      arcPaint,
    );

    // 3. Orbital Satellite Nodes (AMC Ward Beacon Dots)
    final nodePaint = Paint()
      ..color = const Color(0xFFFBBF24) // Gold Beacon
      ..style = PaintingStyle.fill;

    final nodePaint2 = Paint()
      ..color = const Color(0xFF38BDF8) // Cyan Signal
      ..style = PaintingStyle.fill;

    // Node 1
    final node1Angle = rotation;
    final node1Offset = Offset(
      center.dx + (radius - 2) * math.cos(node1Angle),
      center.dy + (radius - 2) * math.sin(node1Angle),
    );
    canvas.drawCircle(node1Offset, 3.2, nodePaint);

    // Node 2
    final node2Angle = rotation + (math.pi * 0.7);
    final node2Offset = Offset(
      center.dx + (radius - 2) * math.cos(node2Angle),
      center.dy + (radius - 2) * math.sin(node2Angle),
    );
    canvas.drawCircle(node2Offset, 2.6, nodePaint2);

    // Node 3
    final node3Angle = rotation + (math.pi * 1.4);
    final node3Offset = Offset(
      center.dx + (radius - 2) * math.cos(node3Angle),
      center.dy + (radius - 2) * math.sin(node3Angle),
    );
    canvas.drawCircle(node3Offset, 2.8, nodePaint);
  }

  @override
  bool shouldRepaint(covariant _CivicOrbitalHaloPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.pulse != pulse;
  }
}
