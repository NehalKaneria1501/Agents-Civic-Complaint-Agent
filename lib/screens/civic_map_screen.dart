import 'package:flutter/material.dart';
import '../models/civic_models.dart';
import '../services/amc_database.dart';
import '../services/google_maps_service.dart';
import '../theme/civic_colors.dart';

// ==========================================
// CIVIC GOOGLE MAP SCREEN
// Visual GIS Cadastral Map for Ahmedabad Municipal Corporation
// Displays live incident pins with direct Google Maps integration & turn-by-turn navigation
// ==========================================

class CivicMapScreen extends StatefulWidget {
  final Function(CivicTicket)? onSelectTicket;

  const CivicMapScreen({super.key, this.onSelectTicket});

  @override
  State<CivicMapScreen> createState() => _CivicMapScreenState();
}

class _CivicMapScreenState extends State<CivicMapScreen> {
  String _selectedCategory = 'All';
  CivicTicket? _activeSelectedTicket;

  // Key Ahmedabad Municipal GIS Landmarks
  final List<Map<String, dynamic>> _landmarkPins = [
    {
      'title': 'Atal Pedestrian Bridge',
      'lat': 23.0258,
      'lng': 72.5714,
      'type': 'landmark',
      'area': 'Sabarmati Riverfront East',
      'icon': Icons.directions_walk_rounded,
      'color': CivicColors.primary,
    },
    {
      'title': 'Narendra Modi Stadium',
      'lat': 23.0916,
      'lng': 72.5975,
      'type': 'landmark',
      'area': 'Motera Sports Enclave',
      'icon': Icons.sports_cricket_rounded,
      'color': CivicColors.secondary,
    },
    {
      'title': 'Akshardham Gandhinagar',
      'lat': 23.2307,
      'lng': 72.6738,
      'type': 'landmark',
      'area': 'Sector 20 Gandhinagar Corridor',
      'icon': Icons.temple_hindu_rounded,
      'color': CivicColors.tertiary,
    },
    {
      'title': 'AMC Central Command HQ',
      'lat': 23.0225,
      'lng': 72.5714,
      'type': 'hq',
      'area': 'Danapith Central Zone',
      'icon': Icons.account_balance_rounded,
      'color': CivicColors.primary,
    },
  ];

  @override
  void initState() {
    super.initState();
    final tickets = AmcDatabase.instance.tickets;
    if (tickets.isNotEmpty) {
      _activeSelectedTicket = tickets.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tickets = AmcDatabase.instance.tickets;
    final filteredTickets = _selectedCategory == 'All'
        ? tickets
        : tickets.where((t) => t.issueCategory.toLowerCase().contains(_selectedCategory.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: CivicColors.surface,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AMC Civic GIS Map', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text('Integrated with Google Maps Platform', style: TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: CivicColors.primary),
            tooltip: 'Center on Ahmedabad HQ',
            onPressed: () {
              GoogleMapsService.openMapLocation(
                latitude: 23.0225,
                longitude: 72.5714,
                label: 'Ahmedabad Municipal Corporation HQ',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.map_rounded, color: CivicColors.secondary),
            tooltip: 'Open in Google Maps App',
            onPressed: () {
              if (_activeSelectedTicket != null) {
                final coords = GoogleMapsService.parseGpsCoordinates(_activeSelectedTicket!.area);
                GoogleMapsService.openMapLocation(
                  latitude: coords?.key ?? 23.0365,
                  longitude: coords?.value ?? 72.5126,
                  label: _activeSelectedTicket!.title,
                );
              } else {
                GoogleMapsService.openMapLocation(latitude: 23.0225, longitude: 72.5714, label: 'Ahmedabad AMC');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Row
          _buildFilterChips(),

          // Interactive Map Canvas with Pins
          Expanded(
            child: Stack(
              children: [
                _buildMapCanvas(filteredTickets),
                // Top Status Badge
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: _buildLiveGisBanner(filteredTickets.length),
                ),
              ],
            ),
          ),

          // Bottom Selected Ticket Card
          if (_activeSelectedTicket != null) _buildSelectedTicketPanel(_activeSelectedTicket!),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final categories = ['All', 'Pothole', 'Waste', 'Streetlight', 'Water'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(cat == 'Water' ? 'Waterlogging' : cat),
                selectedColor: CivicColors.primaryContainer,
                checkmarkColor: CivicColors.onPrimaryContainer,
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? CivicColors.onPrimaryContainer : CivicColors.onSurface,
                ),
                onSelected: (_) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLiveGisBanner(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: CivicColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.satellite_alt_rounded, color: CivicColors.primary, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Showing $count municipal incident pins in Ahmedabad Ward 4',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
            ),
          ),
          const SizedBox(width: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: TextButton.icon(
              onPressed: () {
                GoogleMapsService.openMapLocation(
                  latitude: 23.0365,
                  longitude: 72.5126,
                  label: 'AMC Active Civic Clusters',
                );
              },
              icon: const Icon(Icons.open_in_new_rounded, size: 14),
              label: const Text('Google Maps', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCanvas(List<CivicTicket> tickets) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECEF),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFDEE5EA),
            const Color(0xFFF0F4F8),
            const Color(0xFFE1E8EE),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _AhmedabadMapGridPainter(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 70, bottom: 20, left: 16, right: 16),
          child: Column(
            children: [
              // Landmark Pins
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ..._landmarkPins.map((lm) => _buildLandmarkChip(lm)),
                  ...tickets.map((t) => _buildTicketPinChip(t)),
                ],
              ),
              const SizedBox(height: 24),
              // Call to Action Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.explore_rounded, color: CivicColors.primary, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'Live Google Maps Navigation Active',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap any pin above to view municipal inspection reports and navigate directly via Google Maps.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: CivicColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        GoogleMapsService.openDirections(
                          destinationLat: 23.0365,
                          destinationLng: 72.5126,
                        );
                      },
                      icon: const Icon(Icons.directions_car_rounded, size: 16),
                      label: const Text('Navigate to Nearest Incident'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CivicColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandmarkChip(Map<String, dynamic> lm) {
    return InkWell(
      onTap: () {
        GoogleMapsService.openMapLocation(
          latitude: lm['lat'] as double,
          longitude: lm['lng'] as double,
          label: lm['title'] as String,
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: (lm['color'] as Color).withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(lm['icon'] as IconData, size: 16, color: lm['color'] as Color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  lm['title'] as String,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Text(
                  lm['area'] as String,
                  style: const TextStyle(fontSize: 9.5, color: CivicColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketPinChip(CivicTicket ticket) {
    final isSelected = _activeSelectedTicket?.ticketId == ticket.ticketId;
    Color pinColor = CivicColors.primary;
    if (ticket.severity == 'Critical') pinColor = const Color(0xFFBA1A1A);
    if (ticket.severity == 'High') pinColor = const Color(0xFFD97706);
    if (ticket.severity == 'Medium') pinColor = CivicColors.secondary;

    return InkWell(
      onTap: () {
        setState(() {
          _activeSelectedTicket = ticket;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? pinColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: pinColor, width: isSelected ? 2 : 1),
          boxShadow: [
            BoxShadow(
              color: pinColor.withValues(alpha: isSelected ? 0.25 : 0.08),
              blurRadius: isSelected ? 10 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ticket.department.icon,
              size: 16,
              color: isSelected ? Colors.white : pinColor,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '#${ticket.ticketId}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : CivicColors.onSurface,
                  ),
                ),
                Text(
                  ticket.severity,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white70 : pinColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedTicketPanel(CivicTicket ticket) {
    final coords = GoogleMapsService.parseGpsCoordinates(ticket.area);
    final lat = coords?.key ?? 23.0365;
    final lng = coords?.value ?? 72.5126;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CivicColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(ticket.department.icon, color: CivicColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${ticket.ticketId} • ${ticket.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '${ticket.ward.wardName} • Status: ${ticket.status}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CivicColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ticket.severity,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CivicColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      GoogleMapsService.openMapLocation(
                        latitude: lat,
                        longitude: lng,
                        label: ticket.title,
                      );
                    },
                    icon: const Icon(Icons.place_rounded, size: 16),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Open Map', style: TextStyle(fontSize: 12)),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      GoogleMapsService.openDirections(
                        destinationLat: lat,
                        destinationLng: lng,
                      );
                    },
                    icon: const Icon(Icons.directions_rounded, size: 16),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Directions', style: TextStyle(fontSize: 12)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CivicColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                if (widget.onSelectTicket != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: CivicColors.primary),
                    tooltip: 'Inspect Details',
                    onPressed: () => widget.onSelectTicket!(ticket),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AhmedabadMapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    // Grid lines resembling GIS street layouts
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    // Sabarmati River curve representation
    final riverPaint = Paint()
      ..color = const Color(0xFF64B5F6).withValues(alpha: 0.25)
      ..strokeWidth = 18.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.42, 0)
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.45,
        size.width * 0.38,
        size.height,
      );

    canvas.drawPath(path, riverPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
