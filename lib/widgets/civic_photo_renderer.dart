import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// ==========================================
// RESILIENT CIVIC PHOTO RENDERER & INSPECTION SCENE
// Supports offline procedural fallbacks, camera captures, gallery files
// ==========================================

class CivicPhotoRenderer extends StatefulWidget {
  final String? photoUrl;
  final String? category;
  final String? title;
  final String? gpsCoords;
  final double height;
  final double width;
  final BorderRadius? borderRadius;
  final String? badge;
  final Color? badgeColor;
  final bool showBadge;
  final bool isViewfinder;
  final Widget? customOverlay;

  const CivicPhotoRenderer({
    super.key,
    required this.photoUrl,
    this.category,
    this.title,
    this.gpsCoords,
    this.height = 160,
    this.width = double.infinity,
    this.borderRadius,
    this.badge,
    this.badgeColor,
    this.showBadge = true,
    this.isViewfinder = false,
    this.customOverlay,
  });

  @override
  State<CivicPhotoRenderer> createState() => _CivicPhotoRendererState();
}

class _CivicPhotoRendererState extends State<CivicPhotoRenderer> {
  String? get photoUrl => widget.photoUrl;
  String? get category => widget.category;
  String? get title => widget.title;
  String? get gpsCoords => widget.gpsCoords;
  double get height => widget.height;
  double get width => widget.width;
  BorderRadius? get borderRadius => widget.borderRadius;
  String? get badge => widget.badge;
  Color? get badgeColor => widget.badgeColor;
  bool get showBadge => widget.showBadge;
  bool get isViewfinder => widget.isViewfinder;
  Widget? get customOverlay => widget.customOverlay;


  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(16);
    final scene = _getIncidentScene(category, title);
    final overlay = customOverlay;

    return ClipRRect(
      borderRadius: br,
      child: SizedBox(
        height: height,
        width: width,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;
            final isCompact = availableHeight < 90 || availableWidth < 120;
            final isMid = availableWidth < 220;

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. High-Fidelity Procedural Incident Scene (Guaranteed Offline / Fallback)
                _buildProceduralScene(scene),

                // 2. Real Photo Renderer (Camera local captures, gallery files, assets, base64, or network URLs)
                _buildImageContent(context, scene),

                // 3. Cinematic Lighting & Contrast Vignette
                if (!isCompact)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),

                // 4. Viewfinder Camera Reticle (if isViewfinder)
                if (isViewfinder && !isCompact)
                  CustomPaint(
                    painter: _ViewfinderReticlePainter(accentColor: scene.accentColor),
                  ),

                // 5. Header Badge (e.g. 'Live Geotag Camera', 'Initial Report', etc.)
                if (showBadge && !isCompact && (badge != null || isViewfinder))
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (badgeColor ?? Colors.black).withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isViewfinder ? const Color(0xFF10B981) : scene.accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    badge ?? (isViewfinder ? 'Live Lens' : 'Evidence'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isViewfinder && !isMid)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'AI 4K • HDR',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                // 6. Footer Geotag & Metadata Details (hidden if customOverlay is present to avoid collision)
                if (showBadge && !isCompact && customOverlay == null)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (title != null && title!.isNotEmpty)
                                Text(
                                  title!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: scene.accentColor, size: 11),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      gpsCoords ?? 'Ahmedabad Municipal Zone (AMC)',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 9.5,
                                        fontFamily: 'monospace',
                                        shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!isMid) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'GEOTAGGED',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                ?overlay,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageContent(BuildContext context, _IncidentScene scene) {
    final url = photoUrl?.trim();
    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }

    // 1. Asset Image
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    }

    // 2. Data URI / Base64 Encoded Image
    if (url.startsWith('data:image')) {
      try {
        final commaIdx = url.indexOf(',');
        final base64Data = commaIdx != -1 ? url.substring(commaIdx + 1) : url;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        );
      } catch (_) {
        return const SizedBox.shrink();
      }
    }

    // 3. Local Camera Capture or Gallery File Path
    final isLocalFile = !url.startsWith('http://') &&
        !url.startsWith('https://') &&
        (url.startsWith('/') ||
            url.startsWith('file:') ||
            url.contains(RegExp(r'^[a-zA-Z]:[/\\]')) ||
            url.contains('/data/') ||
            url.contains('/storage/'));

    if (isLocalFile) {
      if (kIsWeb) {
        return Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
        );
      } else {
        try {
          final cleanPath = url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
          return Image.file(
            File(cleanPath),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          );
        } catch (_) {
          return const SizedBox.shrink();
        }
      }
    }

    // 4. Remote HTTP / HTTPS Network Photo with Loading HUD & Graceful Fallback
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: scene.baseColor.withValues(alpha: 0.8),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                color: scene.accentColor,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Fall back seamlessly to procedural incident canvas
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProceduralScene(_IncidentScene scene) {
    final iconSize = height.isFinite && height > 0 ? (height * 0.42).clamp(24.0, 140.0) : 64.0;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scene.baseColor, scene.secondaryColor],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _CivicGridPainter(color: Colors.white.withValues(alpha: 0.05)),
          ),
          Center(
            child: Icon(
              scene.icon,
              size: iconSize,
              color: scene.accentColor.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  _IncidentScene _getIncidentScene(String? category, String? title) {
    final cat = (category ?? '').toLowerCase();
    final t = (title ?? '').toLowerCase();

    if (cat.contains('pothole') || t.contains('pothole') || t.contains('road') || cat.contains('road')) {
      return const _IncidentScene(
        baseColor: Color(0xFF1E293B),
        secondaryColor: Color(0xFF0F172A),
        accentColor: Color(0xFFF59E0B),
        icon: Icons.car_crash_rounded,
        label: 'Asphalt Pothole Hazard',
      );
    } else if (cat.contains('garbage') || t.contains('garbage') || cat.contains('waste') || t.contains('dump')) {
      return const _IncidentScene(
        baseColor: Color(0xFF14291F),
        secondaryColor: Color(0xFF0A1811),
        accentColor: Color(0xFF10B981),
        icon: Icons.delete_outline_rounded,
        label: 'Solid Waste & Dump',
      );
    } else if (cat.contains('street') || cat.contains('light') || t.contains('street') || t.contains('light')) {
      return const _IncidentScene(
        baseColor: Color(0xFF0B132B),
        secondaryColor: Color(0xFF1C2541),
        accentColor: Color(0xFFFBBF24),
        icon: Icons.lightbulb_outline_rounded,
        label: 'Streetlight Outage',
      );
    } else if (cat.contains('water') || cat.contains('flood') || cat.contains('drain') || t.contains('water')) {
      return const _IncidentScene(
        baseColor: Color(0xFF0F2B48),
        secondaryColor: Color(0xFF061426),
        accentColor: Color(0xFF38BDF8),
        icon: Icons.water_drop_outlined,
        label: 'Monsoon Flood Drain',
      );
    }

    return const _IncidentScene(
      baseColor: Color(0xFF1E293B),
      secondaryColor: Color(0xFF0F172A),
      accentColor: Color(0xFFF59E0B),
      icon: Icons.warning_amber_rounded,
      label: 'Municipal Hazard Evidence',
    );
  }
}

class _IncidentScene {
  final Color baseColor;
  final Color secondaryColor;
  final Color accentColor;
  final IconData icon;
  final String label;

  const _IncidentScene({
    required this.baseColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.icon,
    required this.label,
  });
}

class _CivicGridPainter extends CustomPainter {
  final Color color;

  _CivicGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ViewfinderReticlePainter extends CustomPainter {
  final Color accentColor;

  _ViewfinderReticlePainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const corner = 18.0;
    const margin = 20.0;
    final r = Rect.fromLTWH(margin, margin, size.width - margin * 2, size.height - margin * 2);

    // Top Left
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(corner, 0), paint);
    canvas.drawLine(r.topLeft, r.topLeft + const Offset(0, corner), paint);

    // Top Right
    canvas.drawLine(r.topRight, r.topRight + const Offset(-corner, 0), paint);
    canvas.drawLine(r.topRight, r.topRight + const Offset(0, corner), paint);

    // Bottom Left
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(corner, 0), paint);
    canvas.drawLine(r.bottomLeft, r.bottomLeft + const Offset(0, -corner), paint);

    // Bottom Right
    canvas.drawLine(r.bottomRight, r.bottomRight + const Offset(-corner, 0), paint);
    canvas.drawLine(r.bottomRight, r.bottomRight + const Offset(0, -corner), paint);

    // Center Crosshair
    final center = size.center(Offset.zero);
    final centerPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.9)
      ..strokeWidth = 1.5;

    const cross = 8.0;
    canvas.drawLine(center - const Offset(cross, 0), center + const Offset(cross, 0), centerPaint);
    canvas.drawLine(center - const Offset(0, cross), center + const Offset(0, cross), centerPaint);
    canvas.drawCircle(center, 14, centerPaint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
