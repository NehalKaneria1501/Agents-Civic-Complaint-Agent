import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/civic_models.dart';
import '../services/amc_database.dart';
import '../theme/civic_colors.dart';
import '../widgets/civic_photo_renderer.dart';
import 'civic_map_screen.dart';
import 'amc_directory_screen.dart';

// ==========================================
// SCREEN: HOME SCREEN (AMC CIVIC DASHBOARD)
// ==========================================

class MunicipalServiceSlide {
  final String title;
  final String subtitle;
  final String department;
  final String category;
  final String badgeText;
  final Color badgeColor;
  final IconData icon;
  final String metrics;
  final String? photoUrl;
  final String sampleIncidentId;

  const MunicipalServiceSlide({
    required this.title,
    required this.subtitle,
    required this.department,
    required this.category,
    required this.badgeText,
    required this.badgeColor,
    required this.icon,
    required this.metrics,
    this.photoUrl,
    required this.sampleIncidentId,
  });
}

class HomeScreen extends StatefulWidget {
  final Function(SampleIncident)? onOpenAgentWithIncident;
  final Function(CivicTicket)? onOpenTicket;
  final VoidCallback? onOpenFeedback;

  const HomeScreen({
    super.key,
    this.onOpenAgentWithIncident,
    this.onOpenTicket,
    this.onOpenFeedback,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeSlideIndex = 0;
  bool _showAllCategories = false;

  static const List<MunicipalServiceSlide> _municipalServices = [
    MunicipalServiceSlide(
      title: 'Solid Waste & Door-to-Door Collection',
      subtitle: '100% daily segregated EV collection across 48 AMC wards & clean Riverfront',
      department: 'Solid Waste Management',
      category: 'Solid Waste',
      badgeText: 'Swachh Bharat AMC',
      badgeColor: Color(0xFF059669),
      icon: Icons.delete_sweep_rounded,
      metrics: '3,800+ MT Daily Collection',
      photoUrl: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?auto=format&fit=crop&w=800&q=80',
      sampleIncidentId: 'garbage',
    ),
    MunicipalServiceSlide(
      title: 'Road Infrastructure & Rapid Jetpatcher',
      subtitle: '24-hour asphalt pothole restoration, pedestrian footpaths & bridge repairs',
      department: 'Engineering & Roads Dept',
      category: 'Roads & Potholes',
      badgeText: 'Vision Zero Roads',
      badgeColor: Color(0xFFD97706),
      icon: Icons.add_road_rounded,
      metrics: '98.4% Potholes Fixed in 24h',
      photoUrl: 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?auto=format&fit=crop&w=800&q=80',
      sampleIncidentId: 'pothole',
    ),
    MunicipalServiceSlide(
      title: 'Purified Water Supply & Drainage Network',
      subtitle: '24/7 Narmada treated tap water supply & mechanised storm drainage desilting',
      department: 'Water & Sewerage Directorate',
      category: 'Water & Drainage',
      badgeText: 'Clean Water Mission',
      badgeColor: Color(0xFF0284C7),
      icon: Icons.water_drop_rounded,
      metrics: '1,450 MLD Daily Water Supply',
      photoUrl: 'https://images.unsplash.com/photo-1541888946425-d0fbb186f5f8?auto=format&fit=crop&w=800&q=80',
      sampleIncidentId: 'waterlogging',
    ),
    MunicipalServiceSlide(
      title: 'Automated Smart LED Streetlight Grid',
      subtitle: '1.5 Lakh centrally monitored smart LED lights with automatic dark-spot alerts',
      department: 'Streetlight & Electrical Dept',
      category: 'Street Lighting',
      badgeText: 'Energy Safe 24/7',
      badgeColor: Color(0xFF7C3AED),
      icon: Icons.lightbulb_rounded,
      metrics: '1,55,000+ Smart Fixtures',
      photoUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?auto=format&fit=crop&w=800&q=80',
      sampleIncidentId: 'streetlight',
    ),
    MunicipalServiceSlide(
      title: 'Urban Public Health & Vector Fogging',
      subtitle: 'Intensive malaria/dengue vector fogging, anti-larval drives & 82 Health Centers',
      department: 'Public Health Department',
      category: 'Public Health',
      badgeText: 'Healthy City Mission',
      badgeColor: Color(0xFFE11D48),
      icon: Icons.local_hospital_rounded,
      metrics: '82 UHCs & 100% Ward Coverage',
      photoUrl: 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?auto=format&fit=crop&w=800&q=80',
      sampleIncidentId: 'garbage',
    ),
    MunicipalServiceSlide(
      title: 'Emergency 101 Fire & Disaster Water Rescue',
      subtitle: 'Rapid 6-minute emergency turnout, hydraulic tower rescues & river rescue boats',
      department: 'Ahmedabad Fire & Emergency Services',
      category: 'Fire & Emergency',
      badgeText: 'Emergency 101',
      badgeColor: Color(0xFFDC2626),
      icon: Icons.local_fire_department_rounded,
      metrics: '6-Minute Average Turnout',
      photoUrl: 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?auto=format&fit=crop&w=800&q=80',
      sampleIncidentId: 'waterlogging',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Agent Status Banner
          _buildAgentBanner(),
          const SizedBox(height: 12),

          // Google Maps GIS & Live Navigation Platform Card
          _buildGisMapsCard(context),
          const SizedBox(height: 18),

          // Municipal Civic Services Image Slider / Carousel
          _buildMunicipalServicesSlider(context),
          const SizedBox(height: 22),

          // Hero Snap & Report Card
          _buildHeroCard(context),
          const SizedBox(height: 18),

          // Direct Feedback & Suggestion / Grievance Portal Banner
          _buildFeedbackGrievanceBanner(context),
          const SizedBox(height: 18),

          // AMC Municipal Governance & 48 Wards Directory Card
          _buildAmcDirectoryCard(context),
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

  Widget _buildGisMapsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E88E5).withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.map_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Google Maps GIS',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0D47A1)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Live Platform',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Explore municipal hazard pins & squad navigation',
                  style: TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CivicMapScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(50, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Open Map', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMunicipalServicesSlider(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_city_rounded, size: 20, color: CivicColors.primary),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Municipal Civic Services',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CivicColors.onSurface,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: CivicColors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'AMC Live Grid',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: CivicColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CarouselSlider(
          options: CarouselOptions(
            height: 215.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 650),
            autoPlayCurve: Curves.easeInOutCubic,
            enlargeCenterPage: true,
            enlargeFactor: 0.12,
            viewportFraction: 0.92,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() {
                _activeSlideIndex = index;
              });
            },
          ),
          items: _municipalServices.map((service) {
            return _buildServiceSlideCard(context, service);
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _municipalServices.asMap().entries.map((entry) {
            final isSelected = _activeSlideIndex == entry.key;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isSelected ? 22.0 : 7.0,
              height: 7.0,
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isSelected ? CivicColors.primary : CivicColors.outlineVariant.withValues(alpha: 0.4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildServiceSlideCard(BuildContext context, MunicipalServiceSlide service) {
    return InkWell(
      onTap: () {
        final incident = sampleIncidents.firstWhere(
          (i) => i.key == service.sampleIncidentId,
          orElse: () => sampleIncidents[0],
        );
        _openCameraSimulationModal(context, incident);
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CivicPhotoRenderer(
                photoUrl: service.photoUrl,
                category: service.category,
                title: service.title,
                gpsCoords: '23.0225° N, 72.5714° E',
                height: 215,
                width: double.infinity,
                showBadge: false,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.88),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final isCompact = constraints.maxHeight < 175;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Badges Row
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: service.badgeColor.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(service.icon, size: 12, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        service.badgeText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                service.metrics,
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

                        // Middle Titles & Subtitles
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                service.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                service.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 11,
                                  height: 1.25,
                                ),
                                maxLines: isCompact ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Bottom Department & Action Button Row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                service.department,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: CivicColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Report',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 11),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackGrievanceBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CivicColors.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: CivicColors.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.rate_review_rounded, color: CivicColors.onSecondaryContainer, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feedback & Complaint Form',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: CivicColors.onSurface,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Submit citizen suggestions, service ratings, or formal grievances directly.',
                  style: TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              widget.onOpenFeedback?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: CivicColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Open Form', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
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

  Widget _buildAmcDirectoryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: CivicColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_rounded, color: CivicColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AMC Governance & 48 Wards',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: CivicColors.onSurface),
                ),
                SizedBox(height: 2),
                Text(
                  'Mayor, Municipal Commissioner (IAS), CP (IPS), Standing Comm. & Wards',
                  style: TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AmcDirectoryScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CivicColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(60, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Directory', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCategories(BuildContext context) {
    final allCategoryTiles = [
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
      _buildCategoryTile(
        context,
        sampleIncidents[0],
        'Water Supply',
        'Pipeline Leaks',
        Icons.plumbing_rounded,
        const Color(0xFF0284C7),
      ),
      _buildCategoryTile(
        context,
        sampleIncidents[1],
        'Encroachment',
        'Estate & Land',
        Icons.storefront_rounded,
        const Color(0xFF9333EA),
      ),
      _buildCategoryTile(
        context,
        sampleIncidents[2],
        'Stray Animals',
        'CNCD Cattle Squad',
        Icons.pets_rounded,
        const Color(0xFFD97706),
      ),
      _buildCategoryTile(
        context,
        sampleIncidents[3],
        'Vector Control',
        'Malaria & Dengue',
        Icons.pest_control_rounded,
        const Color(0xFF10B981),
      ),
    ];

    final displayed = _showAllCategories ? allCategoryTiles : allCategoryTiles.take(4).toList();

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
            InkWell(
              onTap: () {
                setState(() {
                  _showAllCategories = !_showAllCategories;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CivicColors.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CivicColors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _showAllCategories ? 'Show Less' : 'View All (8)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: CivicColors.primary),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showAllCategories ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: CivicColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: GridView.count(
            key: ValueKey<bool>(_showAllCategories),
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.28,
            children: displayed,
          ),
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
