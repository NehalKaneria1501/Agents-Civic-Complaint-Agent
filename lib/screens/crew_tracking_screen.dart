import 'package:flutter/material.dart';
import '../models/civic_models.dart';
import '../theme/civic_colors.dart';

// ==========================================
// SCREEN: CREW LIVE TRACKING #AMC-9482
// Google Stitch AI Screen: 70e916ecc2784261a0482eb36df4cc03
// ==========================================

class CrewLiveTrackingScreen extends StatefulWidget {
  final CivicTicket ticket;
  final VoidCallback onBack;

  const CrewLiveTrackingScreen({
    super.key,
    required this.ticket,
    required this.onBack,
  });

  @override
  State<CrewLiveTrackingScreen> createState() => _CrewLiveTrackingScreenState();
}

class _CrewLiveTrackingScreenState extends State<CrewLiveTrackingScreen> {
  CivicTicket get ticket => widget.ticket;
  VoidCallback get onBack => widget.onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CivicColors.surface,
      appBar: AppBar(
        backgroundColor: CivicColors.surfaceContainerLowest,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: CivicColors.onSurface),
          onPressed: onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crew Live Tracking #${ticket.ticketId}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
            Text(ticket.ward.wardName, style: const TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981), width: 0.8),
            ),
            child: const Row(
              children: [
                Icon(Icons.radar_rounded, size: 14, color: Color(0xFF10B981)),
                SizedBox(width: 4),
                Text('LIVE DISPATCH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Simulated GIS Vector Map
            Container(
              height: 240,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Stack(
                children: [
                  // Painted Route & Grid
                  CustomPaint(
                    size: const Size(double.infinity, 240),
                    painter: _CrewRouteMapPainter(),
                  ),

                  // Overlay Badge: Speed & GPS
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.navigation_rounded, color: Color(0xFF38BDF8), size: 14),
                          SizedBox(width: 4),
                          Text('Squad R4 Moving • 34 km/h', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),

                  // Geotag Pin Info
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Dest: ${ticket.area}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('ETA: 14 Mins (1.8 km)', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Live Telemetry Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CivicColors.surfaceLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CivicColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.fire_truck_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rapid Asphalt Patching Squad R4', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: CivicColors.onSurface)),
                        SizedBox(height: 2),
                        Text('Tata 407 Unit (GJ-01-CZ-4412) • Cold-mix on board', style: TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Squad Leader & Officer Contact Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: CivicColors.secondaryContainer,
                        child: Icon(Icons.engineering_rounded, color: CivicColors.secondary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ramesh Solanki (Squad Lead)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CivicColors.onSurface)),
                            Text('Senior Field Supervisor • ${ticket.ward.wardName}', style: const TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call_rounded, color: CivicColors.primary),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Calling AMC Dispatcher / Squad Lead (155304)...')),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SquadMetric(label: 'Distance', value: '1.8 km away'),
                      _SquadMetric(label: 'Crew Size', value: '4 Technicians'),
                      _SquadMetric(label: 'Material', value: 'Ready (Bitumen)'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Live Timeline Steps
            const Text('Dispatch Progression', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
            const SizedBox(height: 12),
            _buildDispatchStep('Incident Geotagged & Ticket Verified', '10:15 AM', isDone: true),
            _buildDispatchStep('Squad R4 Assigned & Material Loaded', '10:45 AM', isDone: true),
            _buildDispatchStep('En Route via 132 Feet Ring Road', '11:10 AM', isDone: true, isCurrent: true),
            _buildDispatchStep('On-site Patching & Compaction', 'Est. 11:35 AM', isDone: false),
            _buildDispatchStep('Quality Image Verification & Resolved', 'Est. 12:00 PM', isDone: false),
          ],
        ),
      ),
    );
  }

  static Widget _buildDispatchStep(String title, String time, {required bool isDone, bool isCurrent = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent
                  ? const Color(0xFF10B981)
                  : isDone
                      ? CivicColors.primary
                      : Colors.grey.shade300,
            ),
            child: Icon(
              isDone ? Icons.check : Icons.circle,
              color: Colors.white,
              size: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: isCurrent ? CivicColors.onSurface : CivicColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(time, style: const TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _SquadMetric extends StatefulWidget {
  final String label;
  final String value;
  const _SquadMetric({required this.label, required this.value});

  @override
  State<_SquadMetric> createState() => _SquadMetricState();
}

class _SquadMetricState extends State<_SquadMetric> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: CivicColors.onSurface)),
        const SizedBox(height: 2),
        Text(widget.label, style: const TextStyle(fontSize: 10.5, color: CivicColors.onSurfaceVariant)),
      ],
    );
  }
}

class _CrewRouteMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roadCenterPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final routePaint = Paint()
      ..color = const Color(0xFF0EA5E9)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    // Road 1 (horizontal)
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), roadCenterPaint);

    // Road 2 (diagonal)
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.4, size.width * 0.8, size.height * 0.3);
    canvas.drawPath(path, routePaint);

    // Riverfront / Water curve
    final riverPaint = Paint()
      ..color = const Color(0xFF0C4A6E).withValues(alpha: 0.4)
      ..strokeWidth = 22.0
      ..style = PaintingStyle.stroke;
    final riverPath = Path()
      ..moveTo(size.width * 0.05, size.height)
      ..quadraticBezierTo(size.width * 0.15, size.height * 0.5, size.width * 0.35, 0);
    canvas.drawPath(riverPath, riverPaint);

    // Squad Truck Pin (at 40% of route)
    final truckPos = Offset(size.width * 0.38, size.height * 0.48);
    final truckPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawCircle(truckPos, 10, truckPaint);
    canvas.drawCircle(truckPos, 16, Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.3));

    // Incident Destination Pin (at end of route)
    final destPos = Offset(size.width * 0.8, size.height * 0.3);
    final destPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(destPos, 8, destPaint);
    canvas.drawCircle(destPos, 14, Paint()..color = const Color(0xFFEF4444).withValues(alpha: 0.35));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
