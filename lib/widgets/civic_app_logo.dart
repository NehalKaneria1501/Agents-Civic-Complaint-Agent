import 'dart:math' as math;
import 'package:flutter/material.dart';

// ==========================================
// CIVIC APP LOGO: AHMEDABAD-GANDHINAGAR EMBLEM
// Iconic 5-Landmark Combo:
// 1. Sabarmati Riverfront (waterfront promenade & azure ripples)
// 2. Atal Pedestrian Bridge (curved catenary steel arches & cables)
// 3. Ahmedabad-Gandhinagar Metro (aerodynamic train & elevated viaduct)
// 4. Narendra Modi Cricket Stadium (Motera bowl & floodlight towers)
// 5. Gandhinagar Akshardham (golden sandstone shikhara & kalash domes)
// ==========================================

class CivicAppLogo extends StatefulWidget {
  final double size;
  final BorderRadius? borderRadius;
  final bool showShadow;

  const CivicAppLogo({
    super.key,
    this.size = 40,
    this.borderRadius,
    this.showShadow = true,
  });

  @override
  State<CivicAppLogo> createState() => _CivicAppLogoState();
}

class _CivicAppLogoState extends State<CivicAppLogo> {
  double get size => widget.size;
  BorderRadius? get borderRadius => widget.borderRadius;
  bool get showShadow => widget.showShadow;

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(size * 0.26);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: br,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF031B33), // Deep Municipal Midnight Navy
            Color(0xFF073860), // Royal Sabarmati Indigo
            Color(0xFF0A588C), // Civic Vibrant Blue
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF0369A1).withValues(alpha: 0.38),
                  blurRadius: size * 0.25,
                  offset: Offset(0, size * 0.1),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: br,
        child: Stack(
          children: [
            // Custom Multi-Landmark Vector Artwork (Offline & DPI-Independent)
            CustomPaint(
              size: Size(size, size),
              painter: _CivicAhmedabadGandhinagarComboPainter(),
            ),

            // Optional fallback asset overlay with error resilience
            Image.asset(
              'assets/icons/app_icon.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CivicAhmedabadGandhinagarComboPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // -------------------------------------------------------------------------
    // 0. SKYLINE SUNBURST & DAWN AURA
    // -------------------------------------------------------------------------
    final sunGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFBBF24).withValues(alpha: 0.35),
          const Color(0xFFF97316).withValues(alpha: 0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.65, h * 0.24), radius: w * 0.45));
    canvas.drawCircle(Offset(w * 0.65, h * 0.24), w * 0.45, sunGlowPaint);

    // -------------------------------------------------------------------------
    // 1. CRICKET STADIUM: NARENDRA MODI STADIUM (MOTERA) - Upper Left Skyline
    // -------------------------------------------------------------------------
    _paintCricketStadium(canvas, w, h);

    // -------------------------------------------------------------------------
    // 2. GANDHINAGAR AKSHARDHAM MANDIR - Upper Right & Center Heritage
    // -------------------------------------------------------------------------
    _paintAkshardhamMandir(canvas, w, h);

    // -------------------------------------------------------------------------
    // 3. AHMEDABAD-GANDHINAGAR METRO TRAIN & ELEVATED VIADUCT - Midground
    // -------------------------------------------------------------------------
    _paintMetroTransit(canvas, w, h);

    // -------------------------------------------------------------------------
    // 4. ATAL PEDESTRIAN BRIDGE - Foreground Steel Catenary Arch & Cables
    // -------------------------------------------------------------------------
    _paintAtalBridge(canvas, w, h);

    // -------------------------------------------------------------------------
    // 5. SABARMATI RIVERFRONT - Waterfront Promenades & Azure River Ripples
    // -------------------------------------------------------------------------
    _paintSabarmatiRiverfront(canvas, w, h);
  }

  void _paintCricketStadium(Canvas canvas, double w, double h) {
    // Stadium Floodlight Towers (Beaming into the night sky)
    final lightBeamPaint = Paint()
      ..color = const Color(0xFF67E8F9).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Left tower beam
    final leftBeam = Path()
      ..moveTo(w * 0.10, h * 0.16)
      ..lineTo(w * 0.04, 0)
      ..lineTo(w * 0.18, 0)
      ..close();
    canvas.drawPath(leftBeam, lightBeamPaint);

    // Right tower beam
    final rightBeam = Path()
      ..moveTo(w * 0.34, h * 0.18)
      ..lineTo(w * 0.28, 0)
      ..lineTo(w * 0.42, 0)
      ..close();
    canvas.drawPath(rightBeam, lightBeamPaint);

    // Floodlight Mast Pillars
    final towerPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = math.max(1.0, w * 0.015)
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.10, h * 0.16), Offset(w * 0.10, h * 0.32), towerPaint);
    canvas.drawLine(Offset(w * 0.34, h * 0.18), Offset(w * 0.34, h * 0.34), towerPaint);

    // Tower Light Heads
    final lampHeadPaint = Paint()..color = const Color(0xFFE0F2FE);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.10, h * 0.16), width: w * 0.045, height: w * 0.02), lampHeadPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(w * 0.34, h * 0.18), width: w * 0.045, height: w * 0.02), lampHeadPaint);

    // Stadium Outer Bowl Shell (Colossal Elliptical Structure)
    final bowlPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    final bowlRect = Rect.fromCenter(center: Offset(w * 0.22, h * 0.34), width: w * 0.34, height: h * 0.16);
    canvas.drawOval(bowlRect, bowlPaint);

    // Stadium Seating Tier Ring (Saffron & Tricolor Glow)
    final seatingPaint = Paint()
      ..color = const Color(0xFFF97316).withValues(alpha: 0.85) // Motera saffron seating
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, w * 0.022);
    final seatingRect = Rect.fromCenter(center: Offset(w * 0.22, h * 0.33), width: w * 0.28, height: h * 0.11);
    canvas.drawOval(seatingRect, seatingPaint);

    // Iconic Tensile Canopy Roof Ring (White modern membrane)
    final canopyPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, w * 0.025);
    final canopyRect = Rect.fromCenter(center: Offset(w * 0.22, h * 0.32), width: w * 0.32, height: h * 0.13);
    canvas.drawOval(canopyRect, canopyPaint);
  }

  void _paintAkshardhamMandir(Canvas canvas, double w, double h) {
    final sandstonePaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.95) // Heritage sandstone gold
      ..style = PaintingStyle.fill;

    final sandstoneShadow = Paint()
      ..color = const Color(0xFFD97706).withValues(alpha: 0.85) // Rich carved relief shadow
      ..style = PaintingStyle.fill;

    // Central Grand Shikhara Spire
    final centerShikhara = Path()
      ..moveTo(w * 0.65, h * 0.13) // Sacred Kalash tip
      ..lineTo(w * 0.665, h * 0.18)
      ..quadraticBezierTo(w * 0.72, h * 0.30, w * 0.73, h * 0.44)
      ..lineTo(w * 0.57, h * 0.44)
      ..quadraticBezierTo(w * 0.58, h * 0.30, w * 0.635, h * 0.18)
      ..close();
    canvas.drawPath(centerShikhara, sandstoneShadow);

    // Shikhara Tiered Ribs
    final centerRib = Path()
      ..moveTo(w * 0.65, h * 0.13)
      ..lineTo(w * 0.66, h * 0.19)
      ..quadraticBezierTo(w * 0.70, h * 0.30, w * 0.71, h * 0.44)
      ..lineTo(w * 0.61, h * 0.44)
      ..quadraticBezierTo(w * 0.61, h * 0.30, w * 0.64, h * 0.19)
      ..close();
    canvas.drawPath(centerRib, sandstonePaint);

    // Left Flanking Mandapa Dome
    final leftMandapa = Path()
      ..moveTo(w * 0.52, h * 0.24)
      ..quadraticBezierTo(w * 0.57, h * 0.34, w * 0.57, h * 0.46)
      ..lineTo(w * 0.45, h * 0.46)
      ..quadraticBezierTo(w * 0.46, h * 0.34, w * 0.52, h * 0.24)
      ..close();
    canvas.drawPath(leftMandapa, sandstonePaint);

    // Right Flanking Mandapa Dome
    final rightMandapa = Path()
      ..moveTo(w * 0.78, h * 0.24)
      ..quadraticBezierTo(w * 0.84, h * 0.34, w * 0.85, h * 0.46)
      ..lineTo(w * 0.73, h * 0.46)
      ..quadraticBezierTo(w * 0.73, h * 0.34, w * 0.78, h * 0.24)
      ..close();
    canvas.drawPath(rightMandapa, sandstonePaint);

    // Golden Kalash Finials & Amalak Pinnacles
    final goldKalash = Paint()..color = const Color(0xFFF59E0B);
    canvas.drawCircle(Offset(w * 0.65, h * 0.12), w * 0.026, goldKalash);
    canvas.drawCircle(Offset(w * 0.52, h * 0.23), w * 0.018, goldKalash);
    canvas.drawCircle(Offset(w * 0.78, h * 0.23), w * 0.018, goldKalash);

    // Mandir Pillars / Sub-plinth architraves
    final pillarPaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.8)
      ..strokeWidth = math.max(1.0, w * 0.012)
      ..style = PaintingStyle.stroke;
    for (double px = 0.48; px <= 0.82; px += 0.06) {
      canvas.drawLine(Offset(w * px, h * 0.44), Offset(w * px, h * 0.49), pillarPaint);
    }
  }

  void _paintMetroTransit(Canvas canvas, double w, double h) {
    // Elevated Metro Viaduct Track Deck
    final trackPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = math.max(2.0, w * 0.038)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final viaductPath = Path()
      ..moveTo(0, h * 0.53)
      ..quadraticBezierTo(w * 0.5, h * 0.49, w, h * 0.52);
    canvas.drawPath(viaductPath, trackPaint);

    // Concrete Viaduct Piers (supporting pillars)
    final pierPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = math.max(1.5, w * 0.022)
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.20, h * 0.53), Offset(w * 0.20, h * 0.64), pierPaint);
    canvas.drawLine(Offset(w * 0.50, h * 0.50), Offset(w * 0.50, h * 0.64), pierPaint);
    canvas.drawLine(Offset(w * 0.80, h * 0.52), Offset(w * 0.80, h * 0.64), pierPaint);

    // Aerodynamic Ahmedabad-Gandhinagar Metro Train
    final trainBodyPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Train Coach Contour (Streamlined nose)
    final trainPath = Path()
      ..moveTo(w * 0.16, h * 0.51)
      ..lineTo(w * 0.56, h * 0.485)
      ..quadraticBezierTo(w * 0.60, h * 0.485, w * 0.62, h * 0.50)
      ..lineTo(w * 0.58, h * 0.525)
      ..lineTo(w * 0.16, h * 0.525)
      ..close();
    canvas.drawPath(trainPath, trainBodyPaint);

    // Signature Metro Teal / Cyan Speed Stripe
    final stripePaint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..strokeWidth = math.max(1.0, w * 0.012)
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.16, h * 0.515), Offset(w * 0.59, h * 0.498), stripePaint);

    // Passenger Window Band
    final windowPaint = Paint()..color = const Color(0xFF0F172A);
    for (double wx = 0.20; wx <= 0.52; wx += 0.065) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * wx, h * 0.495, w * 0.045, h * 0.016),
          const Radius.circular(2),
        ),
        windowPaint,
      );
    }

    // Metro Headlight (Glowing LED)
    final headlightPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawCircle(Offset(w * 0.61, h * 0.508), w * 0.012, headlightPaint);
  }

  void _paintAtalBridge(Canvas canvas, double w, double h) {
    // Atal Bridge Signature Catenary Tubular Arches
    final bridgeGlowPaint = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.6)
      ..strokeWidth = math.max(3.0, w * 0.075)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final bridgeSteelPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = math.max(2.0, w * 0.045)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Curved sweeping arch traversing the Sabarmati River
    final atalArch = Path()
      ..moveTo(w * 0.04, h * 0.74)
      ..cubicTo(w * 0.25, h * 0.46, w * 0.75, h * 0.46, w * 0.96, h * 0.74);

    canvas.drawPath(atalArch, bridgeGlowPaint);
    canvas.drawPath(atalArch, bridgeSteelPaint);

    // Vibrant Magenta / Sunset Truss Accents (Iconic Atal Bridge LED Theme)
    final trussAccentPaint = Paint()
      ..color = const Color(0xFFF43F5E).withValues(alpha: 0.85)
      ..strokeWidth = math.max(1.2, w * 0.02)
      ..style = PaintingStyle.stroke;

    final innerArch = Path()
      ..moveTo(w * 0.12, h * 0.72)
      ..cubicTo(w * 0.30, h * 0.52, w * 0.70, h * 0.52, w * 0.88, h * 0.72);
    canvas.drawPath(innerArch, trussAccentPaint);

    // Atal Pedestrian Walkway Deck
    final deckPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = math.max(1.8, w * 0.032)
      ..style = PaintingStyle.stroke;
    final deckPath = Path()
      ..moveTo(w * 0.02, h * 0.73)
      ..quadraticBezierTo(w * 0.5, h * 0.66, w * 0.98, h * 0.73);
    canvas.drawPath(deckPath, deckPaint);

    // Kite-inspired geometric suspension cables
    final cablePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..strokeWidth = math.max(0.8, w * 0.012);

    final cablePositions = [0.22, 0.30, 0.38, 0.46, 0.54, 0.62, 0.70, 0.78];
    for (final cx in cablePositions) {
      // Calculate approximate arch height at cx
      final archY = h * 0.48 + math.pow((cx - 0.50) / 0.45, 2) * (h * 0.24);
      final deckY = h * 0.66 + math.pow((cx - 0.50) / 0.48, 2) * (h * 0.07);
      canvas.drawLine(Offset(w * cx, archY), Offset(w * cx, deckY), cablePaint);
    }
  }

  void _paintSabarmatiRiverfront(Canvas canvas, double w, double h) {
    // Riverfront Promenade Embankment & Coping Wall
    final promenadePaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;
    final promenadeWall = Path()
      ..moveTo(0, h * 0.75)
      ..lineTo(w, h * 0.75)
      ..lineTo(w, h * 0.79)
      ..lineTo(0, h * 0.79)
      ..close();
    canvas.drawPath(promenadeWall, promenadePaint);

    // Promenade Pedestrian Bollard Glows
    final bollardPaint = Paint()..color = const Color(0xFFFDE047);
    for (double bx = 0.08; bx <= 0.95; bx += 0.14) {
      canvas.drawCircle(Offset(w * bx, h * 0.765), math.max(1.0, w * 0.012), bollardPaint);
    }

    // Sabarmati River Water Body (Rich Flowing Azure Waves)
    final riverGradient = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF0284C7), // Vibrant Atal Cyan
          Color(0xFF0369A1), // Deep Sabarmati Azure
          Color(0xFF082F49), // Deep River Basin
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.78, w, h * 0.22));

    final riverPath = Path()
      ..moveTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.25, h * 0.76, w * 0.50, h * 0.79)
      ..quadraticBezierTo(w * 0.75, h * 0.82, w, h * 0.78)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(riverPath, riverGradient);

    // River Water Highlight Ripples (Reflecting city lights)
    final ripplePaint1 = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
      ..strokeWidth = math.max(1.0, w * 0.016)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final ripple1 = Path()
      ..moveTo(w * 0.12, h * 0.85)
      ..quadraticBezierTo(w * 0.35, h * 0.88, w * 0.58, h * 0.85);
    canvas.drawPath(ripple1, ripplePaint1);

    final ripplePaint2 = Paint()
      ..color = const Color(0xFF7DD3FC).withValues(alpha: 0.5)
      ..strokeWidth = math.max(0.9, w * 0.012)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final ripple2 = Path()
      ..moveTo(w * 0.42, h * 0.92)
      ..quadraticBezierTo(w * 0.68, h * 0.95, w * 0.92, h * 0.91);
    canvas.drawPath(ripple2, ripplePaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
