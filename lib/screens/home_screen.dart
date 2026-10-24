import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/civic_models.dart';
import '../services/amc_database.dart';
import '../theme/civic_colors.dart';
import '../widgets/civic_photo_renderer.dart';

// ==========================================
// SCREEN: HOME SCREEN (AMC CIVIC DASHBOARD)
// ==========================================

class HomeScreen extends StatefulWidget {
  final Function(SampleIncident)? onOpenAgentWithIncident;
  final Function(CivicTicket)? onOpenTicket;

  const HomeScreen({
    super.key,
    this.onOpenAgentWithIncident,
    this.onOpenTicket,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Agent Status Banner
          _buildAgentBanner(),
          const SizedBox(height: 18),

          // Hero Snap & Report Card
          _buildHeroCard(context),
          const SizedBox(height: 24),

          // Quick Category Tiles (2x2 Grid)
          _buildQuickCategories(context),
          const SizedBox(height: 24),

          // Recent Ward Ticker
          _buildWardTicker(context),
        ],
      ),
    );
  }

  Widget _buildAgentBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CivicColors.primaryContainer.withValues(alpha: 0.15),
        border: Border.all(color: CivicColors.primary.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: CivicColors.primary,
                  borderRadius: BorderRadius.circular(21),
                ),
                child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'AMC Ward 42 Agent',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: CivicColors.onSurface),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: CivicColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CivicColors.onSecondaryContainer),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'AI Auto-routing & live status sync enabled',
                  style: TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified, color: CivicColors.primary, size: 22),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [CivicColors.primary, CivicColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CivicColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 14),
          const Text(
            'Snap & Report Issue',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.3),
          ),
          const SizedBox(height: 6),
          const Text(
            'Take a photo of a pothole, garbage, or streetlight. AI instantly files it to the right department.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white, height: 1.35),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _openCameraSimulationModal(context, sampleIncidents[0]),
              icon: const Icon(Icons.camera_alt_rounded, color: CivicColors.primary, size: 20),
              label: const Text(
                'Open Camera / Upload Photo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: CivicColors.onSurface),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCategories(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quick Categories',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
            ),
            Text(
              'View All',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CivicColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.28,
          children: [
            _buildCategoryTile(
              context,
              sampleIncidents[0],
              'Pothole',
              'Road & Asphalt',
              Icons.car_crash_rounded,
              CivicColors.primary,
            ),
            _buildCategoryTile(
              context,
              sampleIncidents[1],
              'Garbage',
              'Waste & Dumps',
              Icons.delete_outline_rounded,
              CivicColors.tertiary,
            ),
            _buildCategoryTile(
              context,
              sampleIncidents[2],
              'Streetlight',
              'Outages & Poles',
              Icons.lightbulb_outline_rounded,
              CivicColors.secondary,
            ),
            _buildCategoryTile(
              context,
              sampleIncidents[3],
              'Water Logging',
              'Drainage & Floods',
              Icons.water_drop_outlined,
              CivicColors.primaryContainer,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    SampleIncident incident,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () => _openCameraSimulationModal(context, incident),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: CivicColors.surfaceLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: CivicColors.onSurface),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWardTicker(BuildContext context) {
    final tickets = AmcDatabase.instance.tickets.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Ward Ticker',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Live updates',
                  style: TextStyle(fontSize: 12, color: CivicColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tickets.map((t) => _buildTickerItem(context, t)),
      ],
    );
  }

  Widget _buildTickerItem(BuildContext context, CivicTicket t) {
    Color badgeColor = CivicColors.secondaryContainer;
    Color badgeText = CivicColors.onSecondaryContainer;
    if (t.status == 'Assigned') {
      badgeColor = CivicColors.primaryContainer.withValues(alpha: 0.25);
      badgeText = CivicColors.onPrimaryContainer;
    } else if (t.status == 'Resolved') {
      badgeColor = CivicColors.surfaceHigh;
      badgeText = CivicColors.onSurface;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CivicColors.surfaceLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () {
          if (widget.onOpenTicket != null) widget.onOpenTicket!(t);
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 44,
                height: 44,
                child: CivicPhotoRenderer(
                  photoUrl: t.photoUrl ?? sampleIncidents[0].photoUrl,
                  category: t.issueCategory,
                  title: t.title,
                  height: 44,
                  showBadge: false,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: CivicColors.onSurface),
                  ),
                  Text(
                    'Ticket #${t.ticketId} • ${t.area}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                t.status,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: badgeText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCameraSimulationModal(BuildContext context, SampleIncident incident) {
    _showPhotoCaptureSheet(context, initialIncident: incident);
  }

  void _showPhotoCaptureSheet(BuildContext context, {SampleIncident? initialIncident}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: CivicColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.photo_camera_rounded, color: CivicColors.primary, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Snap & Report Issue',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Capture live hazard with your camera or select an inspection photo from gallery.',
                  style: TextStyle(fontSize: 12.5, color: CivicColors.onSurfaceVariant),
                ),
                const SizedBox(height: 16),

                // 1. Camera Option Tile
                ListTile(
                  tileColor: CivicColors.surfaceContainer.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: CivicColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22),
                  ),
                  title: const Text('Open Camera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Capture live photo of pothole, garbage, or streetlight', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final photo = await pickCivicPhoto(context: context, source: ImageSource.camera);
                    if (photo != null && context.mounted) {
                      _showInspectionViewfinderModal(context, photo);
                    }
                  },
                ),
                const SizedBox(height: 10),

                // 2. Gallery Option Tile
                ListTile(
                  tileColor: CivicColors.surfaceContainer.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: CivicColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 22),
                  ),
                  title: const Text('Upload from Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Select existing evidence photo from device album', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final photo = await pickCivicPhoto(context: context, source: ImageSource.gallery);
                    if (photo != null && context.mounted) {
                      _showInspectionViewfinderModal(context, photo);
                    }
                  },
                ),
                const SizedBox(height: 14),

                // 3. Preset Simulation Option (for Emulators / Testing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Or try a demo scenario:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: CivicColors.onSurfaceVariant)),
                    TextButton(
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showInspectionViewfinderModal(context, initialIncident ?? sampleIncidents[0]);
                      },
                      child: const Text('Use Simulation', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: sampleIncidents.map((s) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: Icon(s.icon, size: 14, color: s.accentColor),
                          label: Text(s.title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showInspectionViewfinderModal(context, s);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInspectionViewfinderModal(BuildContext context, SampleIncident incident) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CivicColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.photo_camera_rounded, color: CivicColors.primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'AI Camera Viewfinder',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Photo attached with live geotagging and HUD reticle.',
                style: TextStyle(fontSize: 12, color: CivicColors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              // Viewfinder Container with Resilient CivicPhotoRenderer
              CivicPhotoRenderer(
                photoUrl: incident.photoUrl,
                category: incident.departmentKey,
                title: incident.title,
                gpsCoords: incident.gpsCoords,
                height: 180,
                isViewfinder: true,
                badge: 'Live Geotag Camera',
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showPhotoCaptureSheet(context, initialIncident: incident);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Retake / Change', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (widget.onOpenAgentWithIncident != null) {
                          widget.onOpenAgentWithIncident!(incident);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CivicColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Analyze & File', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
