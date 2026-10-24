import 'package:flutter/material.dart';
import '../theme/civic_colors.dart';

// ==========================================
// CIVIC APP LOGO: ATAL BRIDGE & AKSHARDHAM COMBO
// Combines Ahmedabad's iconic Atal Pedestrian Bridge &
// Akshardham Mandir heritage architecture in a modern civic emblem
// ==========================================

class CivicAppLogo extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(size * 0.26);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: br,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF003751), // Deep Municipal Navy
            CivicColors.primary, // Civic Blue
            Color(0xFF0284C7), // Atal Sky Cyan
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: CivicColors.primary.withValues(alpha: 0.35),
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
            // Custom Vector Artwork: Atal Bridge + Akshardham Shikhara
            CustomPaint(
              size: Size(size, size),
              painter: _AtalAkshardhamComboPainter(),
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

class _AtalAkshardhamComboPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Akshardham Central & Side Shikhara (Temple Domes in Gold & Sandstone)
    final templePaint = Paint()
      ..color = const Color(0xFFFDE68A).withValues(alpha: 0.85) // Sandstone gold
      ..style = PaintingStyle.fill;

    final templeGlowPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // Central Grand Shikhara Dome
    final centerDome = Path()
      ..moveTo(w * 0.5, h * 0.16) // Kalash tip
      ..lineTo(w * 0.52, h * 0.22)
      ..quadraticBezierTo(w * 0.58, h * 0.38, w * 0.60, h * 0.52)
      ..lineTo(w * 0.40, h * 0.52)
      ..quadraticBezierTo(w * 0.42, h * 0.38, w * 0.48, h * 0.22)
      ..close();
    canvas.drawPath(centerDome, templeGlowPaint);
    canvas.drawPath(centerDome, templePaint);

    // Left Side Shikhara Dome
    final leftDome = Path()
      ..moveTo(w * 0.34, h * 0.28)
      ..quadraticBezierTo(w * 0.40, h * 0.42, w * 0.41, h * 0.54)
      ..lineTo(w * 0.27, h * 0.54)
      ..quadraticBezierTo(w * 0.28, h * 0.42, w * 0.34, h * 0.28)
      ..close();
    canvas.drawPath(leftDome, templePaint);

    // Right Side Shikhara Dome
    final rightDome = Path()
      ..moveTo(w * 0.66, h * 0.28)
      ..quadraticBezierTo(w * 0.72, h * 0.42, w * 0.73, h * 0.54)
      ..lineTo(w * 0.59, h * 0.54)
      ..quadraticBezierTo(w * 0.60, h * 0.42, w * 0.66, h * 0.28)
      ..close();
    canvas.drawPath(rightDome, templePaint);

    // Kalash Finial tips (Golden dots)
    final goldPin = Paint()..color = const Color(0xFFFBBF24);
    canvas.drawCircle(Offset(w * 0.5, h * 0.15), w * 0.03, goldPin);
    canvas.drawCircle(Offset(w * 0.34, h * 0.27), w * 0.022, goldPin);
    canvas.drawCircle(Offset(w * 0.66, h * 0.27), w * 0.022, goldPin);

    // 2. Sabarmati River Waters (Bottom Blue Ripple Curves)
    final riverPaint = Paint()
      ..color = const Color(0xFF0369A1).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final riverPath = Path()
      ..moveTo(0, h * 0.76)
      ..quadraticBezierTo(w * 0.25, h * 0.72, w * 0.5, h * 0.78)
      ..quadraticBezierTo(w * 0.75, h * 0.84, w, h * 0.77)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(riverPath, riverPaint);

    // Water highlight line
    final waterLight = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
      ..strokeWidth = w * 0.02
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.1, h * 0.88), Offset(w * 0.9, h * 0.88), waterLight);

    // 3. Atal Pedestrian Bridge (Curved Catenary Arches & Cable Trusses)
    final bridgeArchPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final bridgeGlowPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Signature Curved Atal Bridge Main Arch
    final atalArch = Path()
      ..moveTo(w * 0.08, h * 0.74)
      ..cubicTo(w * 0.25, h * 0.44, w * 0.75, h * 0.44, w * 0.92, h * 0.74);
    canvas.drawPath(atalArch, bridgeGlowPaint);
    canvas.drawPath(atalArch, bridgeArchPaint);

    // Secondary Deck / Walkway curve
    final deckPaint = Paint()
      ..color = const Color(0xFFE0F2FE)
      ..strokeWidth = w * 0.035
      ..style = PaintingStyle.stroke;
    final deckPath = Path()
      ..moveTo(w * 0.04, h * 0.72)
      ..quadraticBezierTo(w * 0.5, h * 0.65, w * 0.96, h * 0.72);
    canvas.drawPath(deckPath, deckPaint);

    // Cable Stay Lines
    final cablePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = w * 0.015;

    canvas.drawLine(Offset(w * 0.30, h * 0.56), Offset(w * 0.30, h * 0.68), cablePaint);
    canvas.drawLine(Offset(w * 0.40, h * 0.51), Offset(w * 0.40, h * 0.66), cablePaint);
    canvas.drawLine(Offset(w * 0.50, h * 0.49), Offset(w * 0.50, h * 0.65), cablePaint);
    canvas.drawLine(Offset(w * 0.60, h * 0.51), Offset(w * 0.60, h * 0.66), cablePaint);
    canvas.drawLine(Offset(w * 0.70, h * 0.56), Offset(w * 0.70, h * 0.68), cablePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
