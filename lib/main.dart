import 'dart:async';
import 'dart:convert';
import 'dart:io' show File;
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const CivicAgentApp());
}

// Global Alias for tests
typedef MyApp = CivicAgentApp;

// ==========================================
// STITCH DESIGN SYSTEM COLOR & STYLE TOKENS
// Project: 857795515440442716 (Civic Issue Reporting Agent)
// ==========================================

class CivicColors {
  static const primary = Color(0xFF006591);
  static const primaryContainer = Color(0xFF0EA5E9);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF003751);

  static const secondary = Color(0xFF006A63);
  static const secondaryContainer = Color(0xFF99EFE5);
  static const onSecondaryContainer = Color(0xFF006F67);

  static const tertiary = Color(0xFF8A5100);
  static const tertiaryContainer = Color(0xFFDE8712);

  static const surface = Color(0xFFF8F9FF);
  static const surfaceLow = Color(0xFFEFF4FF);
  static const surfaceContainer = Color(0xFFE5EEFF);
  static const surfaceHigh = Color(0xFFDCE9FF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);

  static const onSurface = Color(0xFF0B1C30);
  static const onSurfaceVariant = Color(0xFF3E4850);
  static const outlineVariant = Color(0xFFBEC8D2);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
}

// ==========================================
// MOCK AMC DATA & MODELS
// ==========================================

class WardInfo {
  final String wardName;
  final int wardNumber;
  final String zone;
  final String wardOffice;
  final String inspectorName;
  final String phone;

  const WardInfo({
    required this.wardName,
    required this.wardNumber,
    required this.zone,
    required this.wardOffice,
    required this.inspectorName,
    required this.phone,
  });
}

class DepartmentInfo {
  final String code;
  final String name;
  final String headOfficer;
  final int slaHours;
  final IconData icon;

  const DepartmentInfo({
    required this.code,
    required this.name,
    required this.headOfficer,
    required this.slaHours,
    required this.icon,
  });
}

class CivicTicket {
  final String ticketId;
  final String title;
  final String issueCategory;
  final String description;
  final String severity;
  final String area;
  final WardInfo ward;
  final DepartmentInfo department;
  final DateTime createdAt;
  String status; // 'Registered', 'Assigned', 'In Progress', 'Resolved'
  String? fieldNotes;
  String? squadId;
  String? photoUrl;
  String? followUpPhotoUrl;
  int depthCm;
  bool isEscalated;

  CivicTicket({
    required this.ticketId,
    required this.title,
    required this.issueCategory,
    required this.description,
    required this.severity,
    required this.area,
    required this.ward,
    required this.department,
    required this.createdAt,
    required this.status,
    this.fieldNotes,
    this.squadId,
    this.photoUrl,
    this.followUpPhotoUrl,
    this.depthCm = 15,
    this.isEscalated = false,
  });

  Map<String, dynamic> toJson() => {
    'ticket_id': ticketId,
    'title': title,
    'category': issueCategory,
    'description': description,
    'severity': severity,
    'area': area,
    'ward_number': ward.wardNumber,
    'ward_name': ward.wardName,
    'zone': ward.zone,
    'department': department.name,
    'assigned_officer': ward.inspectorName,
    'squad_id': squadId ?? 'SQUAD-AMC-07',
    'status': status,
    'sla_target': '${department.slaHours} hours',
    'created_at': createdAt.toIso8601String(),
    'field_notes': fieldNotes ?? 'Complaint logged via AI Grievance Assistant.',
    'depth_cm': depthCm,
    'is_escalated': isEscalated,
  };
}

class AmcDatabase {
  static final AmcDatabase instance = AmcDatabase._internal();
  AmcDatabase._internal() {
    _seedInitialTickets();
  }

  final List<CivicTicket> tickets = [];

  final Map<String, WardInfo> wardRegistry = {
    'ward 4': const WardInfo(
      wardName: 'Ward 4 - Central Zone',
      wardNumber: 4,
      zone: 'Central Zone',
      wardOffice: 'AMC Central Zone Complex, Danapith',
      inspectorName: 'Sanjay V. Trivedi (AE)',
      phone: '+91 79 2535 2821',
    ),
    'bodakdev': const WardInfo(
      wardName: 'Bodakdev',
      wardNumber: 12,
      zone: 'North West Zone',
      wardOffice: 'AMC Bodakdev Sub-Civic Center, Judges Bungalow Rd',
      inspectorName: 'Pravin R. Dave (DE)',
      phone: '+91 79 2687 4101',
    ),
    'navrangpura': const WardInfo(
      wardName: 'Navrangpura',
      wardNumber: 8,
      zone: 'West Zone',
      wardOffice: 'West Zone Office, Usmanpura, Ashram Road',
      inspectorName: 'Amit K. Shah (JE)',
      phone: '+91 79 2755 0524',
    ),
    'vastrapur': const WardInfo(
      wardName: 'Vastrapur',
      wardNumber: 13,
      zone: 'North West Zone',
      wardOffice: 'Vastrapur Ward Office, Opp. Lake Garden',
      inspectorName: 'Kishore J. Patel (AE)',
      phone: '+91 79 2676 1239',
    ),
    'sabarmati': const WardInfo(
      wardName: 'Sabarmati',
      wardNumber: 5,
      zone: 'North Zone',
      wardOffice: 'North Zone AMC Complex, Rajiv Gandhi Bhavan',
      inspectorName: 'Chirag M. Vora (AE)',
      phone: '+91 79 2750 6388',
    ),
    'maninagar': const WardInfo(
      wardName: 'Maninagar',
      wardNumber: 27,
      zone: 'South Zone',
      wardOffice: 'South Zone AMC Office, Kankaria Rambaug',
      inspectorName: 'Manish R. Joshi (AE)',
      phone: '+91 79 2546 3311',
    ),
  };

  final Map<String, DepartmentInfo> departments = {
    'pothole': const DepartmentInfo(
      code: 'ROAD_ENG',
      name: 'Roads & Infrastructure Dept',
      headOfficer: 'City Engineer (Roads & Bridges)',
      slaHours: 48,
      icon: Icons.car_crash_rounded,
    ),
    'garbage': const DepartmentInfo(
      code: 'SWM',
      name: 'Solid Waste & Sanitation Dept',
      headOfficer: 'Director of Solid Waste & Sanitation',
      slaHours: 24,
      icon: Icons.delete_outline_rounded,
    ),
    'streetlight': const DepartmentInfo(
      code: 'LIGHT_ENG',
      name: 'Streetlight & Outages Division',
      headOfficer: 'Deputy City Engineer (Electrical)',
      slaHours: 36,
      icon: Icons.lightbulb_outline_rounded,
    ),
    'waterlogging': const DepartmentInfo(
      code: 'DRAINAGE',
      name: 'Drainage & Storm Floods Dept',
      headOfficer: 'Superintending Engineer (Drainage)',
      slaHours: 12,
      icon: Icons.water_drop_outlined,
    ),
  };

  void _seedInitialTickets() {
    tickets.add(
      CivicTicket(
        ticketId: 'AMC-9482',
        title: 'Deep Pothole Hazard',
        issueCategory: 'Pothole & Broken Asphalt',
        description: 'Large surface crater on main carriageway expanding after light rain',
        severity: 'High',
        area: 'Main St & 5th Ave • Ward 4 - Central District',
        ward: wardRegistry['ward 4']!,
        department: departments['pothole']!,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'In Progress',
        fieldNotes: 'Team Alpha (3 personnel) dispatched with asphalt cold-patch roller.',
        squadId: 'SQUAD-WZ-04',
        depthCm: 17,
        photoUrl: 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=800',
        followUpPhotoUrl: 'https://images.unsplash.com/photo-1584463699042-0f9c2d1b7123?w=800',
      ),
    );
    tickets.add(
      CivicTicket(
        ticketId: 'AMC-8821',
        title: 'Deep pothole near 5th Avenue',
        issueCategory: 'Pothole',
        description: 'Dangerous road crater posing two-wheeler accident risk',
        severity: 'High',
        area: '5th Avenue • Ward 12 (Bodakdev)',
        ward: wardRegistry['bodakdev']!,
        department: departments['pothole']!,
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        status: 'In Progress',
        fieldNotes: 'Inspection done; patch crew en route.',
        squadId: 'SQUAD-NWZ-02',
      ),
    );
    tickets.add(
      CivicTicket(
        ticketId: 'AMC-8819',
        title: 'Streetlight non-functional',
        issueCategory: 'Streetlight',
        description: 'Outage on municipal pole #ST-104 hanging fixture',
        severity: 'Medium',
        area: 'Navrangpura CG Road',
        ward: wardRegistry['navrangpura']!,
        department: departments['streetlight']!,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: 'Assigned',
        fieldNotes: 'Assigned to Ward 8 Electrical Squad.',
        squadId: 'SQUAD-WZ-09',
      ),
    );
    tickets.add(
      CivicTicket(
        ticketId: 'AMC-8815',
        title: 'Overflowing bin market street',
        issueCategory: 'Garbage Dump',
        description: 'Commercial waste container spilling onto pedestrian footpath',
        severity: 'Medium',
        area: 'Vastrapur Market',
        ward: wardRegistry['vastrapur']!,
        department: departments['garbage']!,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        status: 'Resolved',
        fieldNotes: 'Dumper placer deployed; area sanitized with lime powder.',
        squadId: 'SQUAD-NWZ-09',
      ),
    );
  }

  WardInfo findWard(String query) {
    final clean = query.trim().toLowerCase();
    for (var key in wardRegistry.keys) {
      if (clean.contains(key) || key.contains(clean)) {
        return wardRegistry[key]!;
      }
    }
    return wardRegistry['ward 4']!;
  }

  DepartmentInfo findDepartment(String categoryKey) {
    final clean = categoryKey.toLowerCase();
    if (clean.contains('pothole') || clean.contains('road')) return departments['pothole']!;
    if (clean.contains('garbage') || clean.contains('waste')) return departments['garbage']!;
    if (clean.contains('light') || clean.contains('streetlight')) return departments['streetlight']!;
    if (clean.contains('water') || clean.contains('drainage')) return departments['waterlogging']!;
    return departments['pothole']!;
  }

  CivicTicket createTicket({
    required String issueCategory,
    required String description,
    required String severity,
    required String area,
    required String departmentKey,
    String? photoUrl,
  }) {
    final rand = Random().nextInt(8999) + 1000;
    final ticketId = 'AMC-$rand';
    final ward = findWard(area);
    final dept = findDepartment(departmentKey);

    final ticket = CivicTicket(
      ticketId: ticketId,
      title: '$issueCategory Hazard',
      issueCategory: issueCategory,
      description: description,
      severity: severity,
      area: area.isNotEmpty ? area : '${ward.wardName} (${ward.zone})',
      ward: ward,
      department: dept,
      createdAt: DateTime.now(),
      status: 'Registered',
      squadId: 'SQUAD-${ward.zone.split(' ').first}-0${Random().nextInt(6) + 1}',
      photoUrl: photoUrl,
      fieldNotes: 'Auto-assigned to ${ward.inspectorName} under ${dept.slaHours}h SLA mandate.',
    );

    tickets.insert(0, ticket);
    return ticket;
  }

  CivicTicket? fetchStatus(String query) {
    if (tickets.isEmpty) return null;
    final upper = query.toUpperCase();
    for (var t in tickets) {
      if (upper.contains(t.ticketId)) {
        return t;
      }
    }
    return tickets.first;
  }

  void advanceTicketStatus(CivicTicket ticket) {
    if (ticket.status == 'Registered') {
      ticket.status = 'Assigned';
      ticket.fieldNotes = 'Assigned to Ward Squad. Field team inspecting today.';
    } else if (ticket.status == 'Assigned') {
      ticket.status = 'In Progress';
      ticket.fieldNotes = 'Field team on site. Repair equipment operating.';
    } else if (ticket.status == 'In Progress') {
      ticket.status = 'Resolved';
      ticket.fieldNotes = 'Work verified by Field Inspector. Site restored and clean.';
    } else {
      ticket.status = 'Registered';
      ticket.fieldNotes = 'Ticket reopened for quality re-check.';
    }
  }
}

// ==========================================
// SAMPLE INCIDENTS (FROM STITCH DESIGN)
// ==========================================

class SampleIncident {
  final String key;
  final String title;
  final String issueCategory;
  final String defaultArea;
  final String description;
  final String severity;
  final String departmentKey;
  final IconData icon;
  final Color accentColor;
  final String gpsCoords;
  final String photoUrl;

  const SampleIncident({
    required this.key,
    required this.title,
    required this.issueCategory,
    required this.defaultArea,
    required this.description,
    required this.severity,
    required this.departmentKey,
    required this.icon,
    required this.accentColor,
    required this.gpsCoords,
    required this.photoUrl,
  });
}

final List<SampleIncident> sampleIncidents = [
  const SampleIncident(
    key: 'pothole',
    title: 'Severe Road Pothole',
    issueCategory: 'Pothole & Broken Asphalt',
    defaultArea: 'Main St & 4th Ave (Ward 4)',
    description: 'Massive surface pothole with cracked asphalt edges expanding after light rain.',
    severity: 'High',
    departmentKey: 'pothole',
    icon: Icons.car_crash_rounded,
    accentColor: CivicColors.primary,
    gpsCoords: '23.0365° N, 72.5126° E (Ward 4)',
    photoUrl: 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=800',
  ),
  const SampleIncident(
    key: 'garbage',
    title: 'Overflowing Garbage Pile',
    issueCategory: 'Solid Waste & Dump',
    defaultArea: 'Vastrapur Market Square',
    description: 'Decomposed organic and plastic waste spilling onto pedestrian footpath.',
    severity: 'Medium',
    departmentKey: 'garbage',
    icon: Icons.delete_outline_rounded,
    accentColor: CivicColors.tertiary,
    gpsCoords: '23.0350° N, 72.5293° E (Vastrapur)',
    photoUrl: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=800',
  ),
  const SampleIncident(
    key: 'streetlight',
    title: 'Dark / Broken Streetlight',
    issueCategory: 'Streetlight Outage',
    defaultArea: 'Navrangpura CG Road',
    description: 'Municipal pole #ST-104 hanging fixture with damaged wiring, completely dark.',
    severity: 'Medium',
    departmentKey: 'streetlight',
    icon: Icons.lightbulb_outline_rounded,
    accentColor: CivicColors.secondary,
    gpsCoords: '23.0373° N, 72.5613° E (Navrangpura)',
    photoUrl: 'https://images.unsplash.com/photo-1516826957135-700dedea698c?w=800',
  ),
  const SampleIncident(
    key: 'waterlogging',
    title: 'Monsoon Water Logging',
    issueCategory: 'Drainage & Storm Floods',
    defaultArea: 'Sabarmati Underpass',
    description: 'Choked storm drain resulting in standing rainwater puddle stalling vehicles.',
    severity: 'Critical',
    departmentKey: 'waterlogging',
    icon: Icons.water_drop_outlined,
    accentColor: CivicColors.primaryContainer,
    gpsCoords: '23.0722° N, 72.5833° E (Sabarmati)',
    photoUrl: 'https://images.unsplash.com/photo-1547683905-f686c993aae5?w=800',
  ),
];

// ==========================================
// CAMERA & GALLERY PHOTO PICKER HELPER
// ==========================================

Future<SampleIncident?> pickCivicPhoto({
  required BuildContext context,
  required ImageSource source,
}) async {
  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final isCamera = source == ImageSource.camera;
    return SampleIncident(
      key: 'user-${DateTime.now().millisecondsSinceEpoch}',
      title: isCamera ? 'Live Camera Capture' : 'Gallery Upload Evidence',
      issueCategory: 'Pothole & Broken Asphalt',
      defaultArea: 'Ahmedabad Municipal Area',
      description: 'Reported incident with photographic evidence captured via user device (${isCamera ? "Camera" : "Gallery"}).',
      severity: 'High',
      departmentKey: 'pothole',
      icon: isCamera ? Icons.photo_camera_rounded : Icons.photo_library_rounded,
      accentColor: CivicColors.primary,
      gpsCoords: '23.0338° N, 72.5467° E (Live GPS)',
      photoUrl: picked.path,
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open ${source == ImageSource.camera ? "camera" : "gallery"}: $e'),
          backgroundColor: CivicColors.error,
        ),
      );
    }
    return null;
  }
}

// ==========================================
// AGENT TOOL CALL MODELS
// ==========================================

enum ToolCallType {
  analyzeImage,
  lookupWardDepartment,
  createTicket,
  fetchStatus,
}

class ToolCallLog {
  final ToolCallType type;
  final String toolName;
  final Map<String, dynamic> arguments;
  final Map<String, dynamic> result;
  final Duration latency;
  bool isExpanded;

  ToolCallLog({
    required this.type,
    required this.toolName,
    required this.arguments,
    required this.result,
    required this.latency,
    this.isExpanded = false,
  });
}

class ChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final DateTime timestamp;
  final SampleIncident? attachedPhoto;
  final String? customImageUrl;
  final List<ToolCallLog> toolCalls;
  final CivicTicket? ticketSummary;
  final bool isDiagnosticAnalysis;

  ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.timestamp,
    this.attachedPhoto,
    this.customImageUrl,
    this.toolCalls = const [],
    this.ticketSummary,
    this.isDiagnosticAnalysis = false,
  });
}

// ==========================================
// ROOT APP WIDGET
// ==========================================

enum AppNavState {
  splash,
  permissions,
  signIn,
  forgotPassword,
  otpVerification,
  mainApp,
}

class CivicAgentApp extends StatefulWidget {
  final bool startWithMainApp;
  const CivicAgentApp({super.key, this.startWithMainApp = false});

  @override
  State<CivicAgentApp> createState() => _CivicAgentAppState();
}

class _CivicAgentAppState extends State<CivicAgentApp> {
  late AppNavState _navState;
  String _phoneNumber = '+91 98765 43210';
  bool _isResetPassword = false;

  // Global Permissions State
  bool _cameraGranted = true;
  bool _locationGranted = true;
  bool _storageGranted = true;
  bool _notificationsGranted = true;

  @override
  void initState() {
    super.initState();
    _navState = widget.startWithMainApp ? AppNavState.mainApp : AppNavState.splash;
  }

  void _navigateTo(AppNavState state) {
    setState(() {
      _navState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AMC Civic Complaint Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: CivicColors.surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CivicColors.primary,
          primary: CivicColors.primary,
          secondary: CivicColors.secondary,
          surface: CivicColors.surface,
        ),
        fontFamily: 'Inter',
      ),
      home: _buildCurrentNavScreen(),
    );
  }

  Widget _buildCurrentNavScreen() {
    switch (_navState) {
      case AppNavState.splash:
        return SplashScreen(
          onGetStarted: () => _navigateTo(AppNavState.permissions),
          onSkipToMain: () => _navigateTo(AppNavState.mainApp),
        );
      case AppNavState.permissions:
        return PermissionsScreen(
          cameraGranted: _cameraGranted,
          locationGranted: _locationGranted,
          storageGranted: _storageGranted,
          notificationsGranted: _notificationsGranted,
          onUpdatePermissions: ({
            required bool camera,
            required bool location,
            required bool storage,
            required bool notifications,
          }) {
            setState(() {
              _cameraGranted = camera;
              _locationGranted = location;
              _storageGranted = storage;
              _notificationsGranted = notifications;
            });
          },
          onContinue: () => _navigateTo(AppNavState.signIn),
          onSkip: () => _navigateTo(AppNavState.signIn),
        );
      case AppNavState.signIn:
        return SignInScreen(
          onSignInSuccess: () => _navigateTo(AppNavState.mainApp),
          onForgotPassword: () {
            _isResetPassword = true;
            _navigateTo(AppNavState.forgotPassword);
          },
          onSignInWithOtp: (phone) {
            _phoneNumber = phone;
            _isResetPassword = false;
            _navigateTo(AppNavState.otpVerification);
          },
          onGuestDemo: () => _navigateTo(AppNavState.mainApp),
        );
      case AppNavState.forgotPassword:
        return ForgotPasswordScreen(
          onBack: () => _navigateTo(AppNavState.signIn),
          onSendOtp: (phone) {
            _phoneNumber = phone;
            _isResetPassword = true;
            _navigateTo(AppNavState.otpVerification);
          },
        );
      case AppNavState.otpVerification:
        return OtpVerificationScreen(
          phoneNumber: _phoneNumber,
          isResetPassword: _isResetPassword,
          onBack: () => _navigateTo(_isResetPassword ? AppNavState.forgotPassword : AppNavState.signIn),
          onVerificationSuccess: () => _navigateTo(AppNavState.mainApp),
        );
      case AppNavState.mainApp:
        return MainShellScreen(
          onSignOut: () => _navigateTo(AppNavState.signIn),
          onManagePermissions: () => _navigateTo(AppNavState.permissions),
        );
    }
  }
}

// ==========================================
// RESILIENT CIVIC PHOTO RENDERER & INSPECTION SCENE
// Supports offline procedural fallbacks, CORS-free graphics, camera reticles
// ==========================================

class CivicPhotoRenderer extends StatelessWidget {
  final String? photoUrl;
  final String? category;
  final String? title;
  final String? gpsCoords;
  final double height;
  final double width;
  final BorderRadius? borderRadius;
  final String? badge;
  final Color? badgeColor;
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
    this.isViewfinder = false,
    this.customOverlay,
  });

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
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. High-Fidelity Procedural Incident Scene (Guaranteed Offline / Fallback)
            _buildProceduralScene(scene),

            // 2. Real Photo Renderer (Camera local captures, gallery files, assets, base64, or network URLs)
            _buildImageContent(context, scene),

            // 3. Cinematic Lighting & Contrast Vignette
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
            if (isViewfinder)
              CustomPaint(
                painter: _ViewfinderReticlePainter(accentColor: scene.accentColor),
              ),

            // 5. Header Badge (e.g. 'Live Geotag Camera', 'Initial Report', etc.)
            if (badge != null || isViewfinder)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                      const SizedBox(width: 6),
                      Text(
                        badge ?? (isViewfinder ? 'AMC Field Survey • Live Lens' : 'Incident Evidence'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 6. Camera Viewfinder Settings Indicator (top right)
            if (isViewfinder)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
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
              ),

            // 7. Footer Geotag & Metadata Details
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
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
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                            ),
                          ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on, color: scene.accentColor, size: 12),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                gpsCoords ?? 'Ahmedabad Municipal Zone (AMC)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'GEOTAGGED',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ?overlay,
          ],
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
              size: height * 0.42,
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
        baseColor: Color(0xFF082F49),
        secondaryColor: Color(0xFF0C4A6E),
        accentColor: Color(0xFF38BDF8),
        icon: Icons.water_drop_outlined,
        label: 'Storm Drainage & Flood',
      );
    }

    return const _IncidentScene(
      baseColor: Color(0xFF0B1C30),
      secondaryColor: Color(0xFF003751),
      accentColor: Color(0xFF0EA5E9),
      icon: Icons.location_city_rounded,
      label: 'Civic Infrastructure',
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
  const _CivicGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CivicGridPainter oldDelegate) => false;
}

class _ViewfinderReticlePainter extends CustomPainter {
  final Color accentColor;
  const _ViewfinderReticlePainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const cornerLen = 16.0;
    const pad = 14.0;

    // Top-Left Corner
    canvas.drawLine(const Offset(pad, pad), const Offset(pad + cornerLen, pad), paint);
    canvas.drawLine(const Offset(pad, pad), const Offset(pad, pad + cornerLen), paint);

    // Top-Right Corner
    canvas.drawLine(Offset(size.width - pad, pad), Offset(size.width - pad - cornerLen, pad), paint);
    canvas.drawLine(Offset(size.width - pad, pad), Offset(size.width - pad, pad + cornerLen), paint);

    // Bottom-Left Corner
    canvas.drawLine(Offset(pad, size.height - pad), Offset(pad + cornerLen, size.height - pad), paint);
    canvas.drawLine(Offset(pad, size.height - pad), Offset(pad, size.height - pad - cornerLen), paint);

    // Bottom-Right Corner
    canvas.drawLine(Offset(size.width - pad, size.height - pad), Offset(size.width - pad - cornerLen, size.height - pad), paint);
    canvas.drawLine(Offset(size.width - pad, size.height - pad), Offset(size.width - pad, size.height - pad + cornerLen), paint);

    // Center Crosshair
    final center = Offset(size.width / 2, size.height / 2);
    final centerPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.7)
      ..strokeWidth = 1.5;

    canvas.drawLine(center - const Offset(12, 0), center + const Offset(12, 0), centerPaint);
    canvas.drawLine(center - const Offset(0, 12), center + const Offset(0, 12), centerPaint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderReticlePainter oldDelegate) => false;
}

// ==========================================
// MAIN SHELL (STITCH 4-TAB NAVIGATION)
// ==========================================

class MainShellScreen extends StatefulWidget {
  final VoidCallback? onSignOut;
  final VoidCallback? onManagePermissions;
  const MainShellScreen({super.key, this.onSignOut, this.onManagePermissions});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;
  CivicTicket? _activeTicketForDetails;
  CivicTicket? _activeTicketForLiveTracking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildStitchTopAppBar(),
      body: _buildCurrentScreen(),
      bottomNavigationBar: _buildStitchBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildStitchTopAppBar() {
    return AppBar(
      backgroundColor: CivicColors.surfaceContainerLowest.withValues(alpha: 0.95),
      elevation: 0,
      scrolledUnderElevation: 1,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/icons/app_icon.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CivicColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'CivicAgent',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CivicColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: CivicColors.onSurfaceVariant),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All municipal notifications caught up.')),
              );
            },
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: CivicColors.primary,
            child: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    if (_activeTicketForLiveTracking != null) {
      return CrewLiveTrackingScreen(
        ticket: _activeTicketForLiveTracking!,
        onBack: () => setState(() => _activeTicketForLiveTracking = null),
      );
    }

    if (_activeTicketForDetails != null) {
      return TicketDetailsView(
        ticket: _activeTicketForDetails!,
        onBack: () => setState(() => _activeTicketForDetails = null),
        onAskAgent: () {
          setState(() {
            _activeTicketForDetails = null;
            _currentIndex = 1; // Go to Agent Chat
          });
        },
        onTrackCrew: () {
          setState(() {
            _activeTicketForLiveTracking = _activeTicketForDetails;
          });
        },
      );
    }

    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          onOpenAgentWithIncident: (incident) {
            setState(() {
              _currentIndex = 1;
            });
          },
          onOpenTicket: (ticket) {
            setState(() {
              _activeTicketForDetails = ticket;
            });
          },
        );
      case 1:
        return AgentChatScreen(
          onViewTicket: (ticket) {
            setState(() {
              _activeTicketForDetails = ticket;
            });
          },
        );
      case 2:
        return TicketsLedgerScreen(
          onOpenTicket: (ticket) {
            setState(() {
              _activeTicketForDetails = ticket;
            });
          },
        );
      case 3:
        return ProfileScreen(
          onSignOut: widget.onSignOut,
          onManagePermissions: widget.onManagePermissions,
        );
      default:
        return const HomeScreen();
    }
  }

  Widget _buildStitchBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: CivicColors.surface.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.smart_toy_rounded, 'Agent'),
              _buildNavItem(2, Icons.receipt_long_rounded, 'Tickets'),
              _buildNavItem(3, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index && _activeTicketForDetails == null;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTicketForDetails = null;
          _currentIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? CivicColors.primaryContainer.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? CivicColors.onPrimaryContainer : CivicColors.onSurfaceVariant,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? CivicColors.onPrimaryContainer : CivicColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// SCREEN 1: HOME & QUICK FILE (STITCH SCREEN)
// ==========================================

class HomeScreen extends StatelessWidget {
  final Function(SampleIncident)? onOpenAgentWithIncident;
  final Function(CivicTicket)? onOpenTicket;

  const HomeScreen({
    super.key,
    this.onOpenAgentWithIncident,
    this.onOpenTicket,
  });

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
          childAspectRatio: 1.5,
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CivicColors.surfaceLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: CivicColors.onSurface),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant),
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
          if (onOpenTicket != null) onOpenTicket!(t);
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CivicColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(t.department.icon, color: CivicColors.primary, size: 20),
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
                        if (onOpenAgentWithIncident != null) {
                          onOpenAgentWithIncident!(incident);
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

// ==========================================
// SCREEN 2: CIVIC AI AGENT CHAT (STITCH SCREEN)
// ==========================================

class AgentChatScreen extends StatefulWidget {
  final Function(CivicTicket)? onViewTicket;

  const AgentChatScreen({super.key, this.onViewTicket});

  @override
  State<AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends State<AgentChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isProcessing = false;
  String _agentStepLabel = '';

  @override
  void initState() {
    super.initState();
    _seedInitialChatFlow();
  }

  void _seedInitialChatFlow() {
    // 1. Initial User photo upload message
    _messages.add(
      ChatMessage(
        id: 'user-01',
        isUser: true,
        text: 'Can you report this massive pothole I just hit on Main Street near 4th Ave?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        attachedPhoto: sampleIncidents[0],
      ),
    );

    // 2. Initial AI Agent Tool Execution Response
    final ticket = AmcDatabase.instance.tickets.first;
    _messages.add(
      ChatMessage(
        id: 'bot-01',
        isUser: false,
        text: "I've received your photo. Running automated municipal diagnostics...",
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        ticketSummary: ticket,
        toolCalls: [
          ToolCallLog(
            type: ToolCallType.analyzeImage,
            toolName: 'analyze_civic_image()',
            arguments: {'image': 'pothole_main_st.jpg', 'mode': 'damage_severity'},
            result: {'detected_issue': 'Pothole (severity high)', 'confidence': 0.98},
            latency: const Duration(milliseconds: 480),
          ),
          ToolCallLog(
            type: ToolCallType.lookupWardDepartment,
            toolName: 'lookup_ward_and_department()',
            arguments: {'gps': '23.0365, 72.5126', 'issue': 'Pothole'},
            result: {'ward': 'Ward 4 - Central Zone', 'dept': 'Roads & Infrastructure Dept'},
            latency: const Duration(milliseconds: 390),
          ),
          ToolCallLog(
            type: ToolCallType.createTicket,
            toolName: 'create_amc_ticket()',
            arguments: {'title': 'Deep Pothole Hazard', 'ward': 4, 'dept': 'ROAD_ENG'},
            result: {'ticket_id': '#AMC-9482', 'status': 'Assigned', 'sla': '48h'},
            latency: const Duration(milliseconds: 520),
          ),
        ],
      ),
    );

    // 3. User status query
    _messages.add(
      ChatMessage(
        id: 'user-02',
        isUser: true,
        text: 'What is the status?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    );

    // 4. AI Agent status answer
    _messages.add(
      ChatMessage(
        id: 'bot-02',
        isUser: false,
        text: 'Ticket **#AMC-9482** is currently **Assigned** to Ward 4 Roads Team. Estimated repair by Thursday.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ticketSummary: ticket,
        toolCalls: [
          ToolCallLog(
            type: ToolCallType.fetchStatus,
            toolName: 'fetch_ticket_status()',
            arguments: {'ticket_id': 'AMC-9482'},
            result: ticket.toJson(),
            latency: const Duration(milliseconds: 320),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleUserMessage(String text, {SampleIncident? samplePhoto}) async {
    final query = text.trim();
    if (query.isEmpty && samplePhoto == null) return;

    _textController.clear();
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          isUser: true,
          text: query.isNotEmpty ? query : 'Report civic issue from photo (${samplePhoto?.title})',
          timestamp: DateTime.now(),
          attachedPhoto: samplePhoto,
        ),
      );
      _isProcessing = true;
      _agentStepLabel = 'CivicBot reviewing municipal query...';
    });
    _scrollToBottom();

    final lower = query.toLowerCase();
    final isStatus = lower.contains('status') || lower.contains('track') || lower.contains('update');

    if (isStatus && samplePhoto == null) {
      await _executeStatusQuery(query);
    } else {
      await _executeFilingPipeline(samplePhoto ?? sampleIncidents[0]);
    }

    setState(() {
      _isProcessing = false;
      _agentStepLabel = '';
    });
    _scrollToBottom();
  }

  Future<void> _executeFilingPipeline(SampleIncident photo) async {
    final tools = <ToolCallLog>[];

    setState(() => _agentStepLabel = 'Executing analyze_civic_image()...');
    await Future.delayed(const Duration(milliseconds: 600));
    tools.add(
      ToolCallLog(
        type: ToolCallType.analyzeImage,
        toolName: 'analyze_civic_image()',
        arguments: {'photo_key': photo.key, 'exif_gps': photo.gpsCoords},
        result: {'issue': photo.issueCategory, 'severity': photo.severity, 'confidence': '98.5%'},
        latency: const Duration(milliseconds: 510),
      ),
    );

    setState(() => _agentStepLabel = 'Executing lookup_ward_and_department()...');
    await Future.delayed(const Duration(milliseconds: 550));
    final ward = AmcDatabase.instance.findWard(photo.defaultArea);
    final dept = AmcDatabase.instance.findDepartment(photo.departmentKey);
    tools.add(
      ToolCallLog(
        type: ToolCallType.lookupWardDepartment,
        toolName: 'lookup_ward_and_department()',
        arguments: {'location': photo.defaultArea, 'category': photo.issueCategory},
        result: {'ward': '${ward.wardName} (${ward.zone})', 'dept': dept.name, 'sla': '${dept.slaHours}h'},
        latency: const Duration(milliseconds: 440),
      ),
    );

    setState(() => _agentStepLabel = 'Executing create_amc_ticket()...');
    await Future.delayed(const Duration(milliseconds: 600));
    final ticket = AmcDatabase.instance.createTicket(
      issueCategory: photo.issueCategory,
      description: photo.description,
      severity: photo.severity,
      area: photo.defaultArea,
      departmentKey: photo.departmentKey,
      photoUrl: photo.photoUrl,
    );
    tools.add(
      ToolCallLog(
        type: ToolCallType.createTicket,
        toolName: 'create_amc_ticket()',
        arguments: {'category': ticket.issueCategory, 'ward': ward.wardNumber},
        result: ticket.toJson(),
        latency: const Duration(milliseconds: 580),
      ),
    );

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          isUser: false,
          text: "I've analyzed your photo. Complaint successfully logged under official municipal SLA.",
          timestamp: DateTime.now(),
          ticketSummary: ticket,
          toolCalls: tools,
        ),
      );
    });
  }

  Future<void> _executeStatusQuery(String query) async {
    setState(() => _agentStepLabel = 'Executing fetch_ticket_status()...');
    await Future.delayed(const Duration(milliseconds: 600));

    final ticket = AmcDatabase.instance.fetchStatus(query);
    if (ticket == null) return;

    final tool = ToolCallLog(
      type: ToolCallType.fetchStatus,
      toolName: 'fetch_ticket_status()',
      arguments: {'query': query, 'ticket_id': ticket.ticketId},
      result: ticket.toJson(),
      latency: const Duration(milliseconds: 340),
    );

    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          isUser: false,
          text: 'Ticket **#${ticket.ticketId}** is currently **${ticket.status}** with ${ticket.department.name}. Estimated repair within ${ticket.department.slaHours} hours.',
          timestamp: DateTime.now(),
          ticketSummary: ticket,
          toolCalls: [tool],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Agent Context Banner
        _buildContextBanner(),

        // Chat Message List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (ctx, i) => _buildMessageRow(_messages[i]),
          ),
        ),

        // Agent Processing Status Bar
        if (_isProcessing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: CivicColors.primary,
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  _agentStepLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

        // Quick Suggestion Pills
        _buildSuggestionPills(),

        // Chat Input Bar
        _buildInputBar(),
      ],
    );
  }

  Widget _buildContextBanner() {
    final ticket = AmcDatabase.instance.tickets.first;
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: CivicColors.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: CivicColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'CivicBot Assistant',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: CivicColors.onSurface),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                    ),
                  ],
                ),
                Text(
                  'Active Municipal Case #${ticket.ticketId}',
                  style: const TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: CivicColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'AI Active',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CivicColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageRow(ChatMessage msg) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: CivicColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.text,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.35),
                  ),
                  if (msg.attachedPhoto != null) ...[
                    const SizedBox(height: 10),
                    CivicPhotoRenderer(
                      photoUrl: msg.attachedPhoto!.photoUrl,
                      category: msg.attachedPhoto!.departmentKey,
                      title: msg.attachedPhoto!.title,
                      gpsCoords: msg.attachedPhoto!.gpsCoords,
                      height: 140,
                      badge: 'Citizen Photo Attachment',
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text('Just now', style: TextStyle(fontSize: 10.5, color: CivicColors.onSurfaceVariant)),
          ],
        ),
      );
    }

    // AI Message
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: CivicColors.primary,
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Agent Thinking / Tool Execution Bento
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: CivicColors.surfaceContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: const TextStyle(fontSize: 13.5, color: CivicColors.onSurface, height: 1.35),
                      ),
                      if (msg.toolCalls.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _buildToolDiagnosticsList(msg.toolCalls),
                      ],
                      if (msg.ticketSummary != null) ...[
                        const SizedBox(height: 12),
                        _buildTrackingIdCard(msg.ticketSummary!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Just now', style: TextStyle(fontSize: 10.5, color: CivicColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolDiagnosticsList(List<ToolCallLog> toolLogs) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: toolLogs.map((tool) {
          String label = tool.toolName;
          if (tool.type == ToolCallType.analyzeImage) {
            label = 'Image Analysis: Pothole detected (severity high)';
          } else if (tool.type == ToolCallType.lookupWardDepartment) {
            label = 'Ward Lookup: Ward 4 - Central Zone';
          } else if (tool.type == ToolCallType.createTicket) {
            label = 'Department Assignment: Roads & Infrastructure Dept';
          } else if (tool.type == ToolCallType.fetchStatus) {
            label = 'Status Fetch: Active Assigned in Ledger';
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: CivicColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: CivicColors.onSurface),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTrackingIdCard(CivicTicket ticket) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CivicColors.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CivicColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: CivicColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tracking ID Generated',
                  style: TextStyle(fontSize: 10.5, color: CivicColors.onSurfaceVariant),
                ),
                Text(
                  '#${ticket.ticketId}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CivicColors.onPrimaryContainer),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (widget.onViewTicket != null) {
                widget.onViewTicket!(ticket);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CivicColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(60, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('View Ticket', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionPills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildPill('What is the status?', Icons.help_outline_rounded, () {
            _handleUserMessage('What is the status?');
          }),
          _buildPill('Report Pothole', Icons.car_crash_rounded, () {
            _handleUserMessage('', samplePhoto: sampleIncidents[0]);
          }),
          _buildPill('Notify Ward Engineer', Icons.contact_phone_outlined, () {
            _handleUserMessage('Notify the ward engineer for immediate repair');
          }),
          _buildPill('View updated timeline', Icons.timeline_rounded, () {
            if (widget.onViewTicket != null) {
              widget.onViewTicket!(AmcDatabase.instance.tickets.first);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildPill(String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 14, color: CivicColors.primary),
        label: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
        backgroundColor: CivicColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: CivicColors.outlineVariant.withValues(alpha: 0.3))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: CivicColors.surfaceLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (val) => _handleUserMessage(val),
                        decoration: const InputDecoration(
                          hintText: 'Message CivicBot...',
                          hintStyle: TextStyle(fontSize: 13, color: CivicColors.onSurfaceVariant),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // Quick Camera Button
                    IconButton(
                      icon: const Icon(Icons.camera_alt_rounded, color: CivicColors.primary, size: 21),
                      tooltip: 'Take Photo with Camera',
                      onPressed: _openCameraFromChat,
                    ),
                    // Attachment / Gallery / Document Picker Button
                    IconButton(
                      icon: const Icon(Icons.attach_file_rounded, color: CivicColors.onSurfaceVariant, size: 20),
                      tooltip: 'Upload from Gallery or Documents',
                      onPressed: _showChatAttachmentOptions,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.small(
              onPressed: () => _handleUserMessage(_textController.text),
              backgroundColor: CivicColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              child: const Icon(Icons.send_rounded, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCameraFromChat() async {
    final photo = await pickCivicPhoto(context: context, source: ImageSource.camera);
    if (photo != null) {
      _handleUserMessage('Reporting civic hazard with captured photo', samplePhoto: photo);
    }
  }

  Future<void> _openGalleryFromChat() async {
    final photo = await pickCivicPhoto(context: context, source: ImageSource.gallery);
    if (photo != null) {
      _handleUserMessage('Reporting civic hazard with gallery photo', samplePhoto: photo);
    }
  }

  void _showChatAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Attach Civic Evidence',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CivicColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: CivicColors.primary, size: 22),
                  ),
                  title: const Text('Take Photo from Camera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Capture live pothole, garbage, or streetlight evidence', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openCameraFromChat();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CivicColors.secondary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: CivicColors.secondary, size: 22),
                  ),
                  title: const Text('Upload Photo from Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Select existing incident photo from your phone gallery', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openGalleryFromChat();
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: CivicColors.tertiary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: CivicColors.tertiary, size: 22),
                  ),
                  title: const Text('Attach Incident Document / PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('Attach municipal complaint notice or inspection document', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    final pdfIncident = SampleIncident(
                      key: 'pdf-${DateTime.now().millisecondsSinceEpoch}',
                      title: 'Municipal Notice / PDF Document',
                      issueCategory: 'Pothole & Broken Asphalt',
                      defaultArea: 'Ahmedabad Municipal Area',
                      description: 'Citizen attached official inspection PDF document for verification.',
                      severity: 'High',
                      departmentKey: 'pothole',
                      icon: Icons.picture_as_pdf_rounded,
                      accentColor: CivicColors.tertiary,
                      gpsCoords: '23.0338° N, 72.5467° E (Document Ref)',
                      photoUrl: sampleIncidents[0].photoUrl,
                    );
                    _handleUserMessage('Attached municipal inspection PDF document', samplePhoto: pdfIncident);
                  },
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 6),
                const Text('Quick Test Scenarios (Demo Presets):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CivicColors.onSurfaceVariant)),
                const SizedBox(height: 8),
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
                            _handleUserMessage('Reporting issue from photo evidence', samplePhoto: s);
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
}

// ==========================================
// SCREEN 3: TICKETS LEDGER SCREEN
// ==========================================

class TicketsLedgerScreen extends StatelessWidget {
  final Function(CivicTicket)? onOpenTicket;

  const TicketsLedgerScreen({super.key, this.onOpenTicket});

  @override
  Widget build(BuildContext context) {
    final tickets = AmcDatabase.instance.tickets;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Tickets & Status',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CivicColors.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tickets.length} Registered',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CivicColors.onPrimaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...tickets.map((t) => _buildTicketCard(context, t)),
        ],
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, CivicTicket t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          if (onOpenTicket != null) onOpenTicket!(t);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: CivicColors.primaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${t.ticketId}',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: CivicColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: t.severity == 'Critical' || t.severity == 'High'
                            ? CivicColors.errorContainer
                            : CivicColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t.severity,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: t.severity == 'Critical' || t.severity == 'High'
                              ? CivicColors.error
                              : CivicColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: t.status == 'In Progress'
                        ? CivicColors.secondaryContainer
                        : t.status == 'Resolved'
                            ? CivicColors.surfaceHigh
                            : CivicColors.primaryContainer.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    t.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: t.status == 'In Progress' ? CivicColors.onSecondaryContainer : CivicColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              t.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              t.area,
              style: const TextStyle(fontSize: 12, color: CivicColors.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.business_outlined, size: 14, color: CivicColors.primary),
                const SizedBox(width: 4),
                Text(
                  t.department.name,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: CivicColors.onSurface),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {
                    AmcDatabase.instance.advanceTicketStatus(t);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ticket #${t.ticketId} updated to ${t.status}! Ask agent in chat for live status.')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: const Size(60, 28),
                  ),
                  child: const Text('Advance Status', style: TextStyle(fontSize: 10.5)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// SCREEN 4: TICKET DETAILS (STITCH SCREEN)
// ==========================================

class TicketDetailsView extends StatefulWidget {
  final CivicTicket ticket;
  final VoidCallback onBack;
  final VoidCallback onAskAgent;
  final VoidCallback? onTrackCrew;

  const TicketDetailsView({
    super.key,
    required this.ticket,
    required this.onBack,
    required this.onAskAgent,
    this.onTrackCrew,
  });

  @override
  State<TicketDetailsView> createState() => _TicketDetailsViewState();
}

class _TicketDetailsViewState extends State<TicketDetailsView> {
  CivicTicket get ticket => widget.ticket;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onBack,
              ),
              const Text(
                'Ticket Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
              ),
              const Spacer(),
              if (!ticket.isEscalated)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      ticket.isEscalated = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⚠️ Ticket escalated to Zonal Chief Engineer (SLA Priority Flagged)!'),
                        backgroundColor: CivicColors.error,
                      ),
                    );
                  },
                  icon: const Icon(Icons.emergency_share, size: 16, color: CivicColors.error),
                  label: const Text('Escalate', style: TextStyle(color: CivicColors.error, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Status Banner Card
          _buildStatusBanner(),
          const SizedBox(height: 16),

          // Photographic Evidence Section
          _buildPhotoEvidenceSection(),
          const SizedBox(height: 16),

          // Timeline & Status History
          _buildTimelineSection(),
          const SizedBox(height: 16),

          // Department Notes
          _buildDepartmentNotes(),
          const SizedBox(height: 18),

          // Action Button: Track Crew Live (Stitch Screen 70e916ecc2784261a0482eb36df4cc03)
          if (widget.onTrackCrew != null) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: widget.onTrackCrew,
                icon: const Icon(Icons.location_searching_rounded, color: Colors.white, size: 20),
                label: const Text(
                  'Track Repair Crew Live (Squad #AMC-R4)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CivicColors.secondary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Action Button: Ask Civic AI Agent
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: widget.onAskAgent,
              icon: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Ask Civic AI Agent about this ticket',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CivicColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CivicColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CivicColors.primaryContainer.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sync_rounded, size: 14, color: CivicColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          ticket.status,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CivicColors.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: CivicColors.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${ticket.severity} Severity',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CivicColors.error),
                    ),
                  ),
                ],
              ),
              Text(
                '#${ticket.ticketId}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CivicColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: CivicColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  ticket.area,
                  style: const TextStyle(fontSize: 12.5, color: CivicColors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Quick Stats Grid
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Assigned Dept', style: TextStyle(fontSize: 10.5, color: CivicColors.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text(
                        ticket.department.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Est. Resolution', style: TextStyle(fontSize: 10.5, color: CivicColors.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text(
                        'Within ${ticket.department.slaHours}h',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoEvidenceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CivicColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.photo_camera_rounded, color: CivicColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text('Photographic Evidence', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
                ],
              ),
              const Text('2 Photos Attached', style: TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CivicPhotoRenderer(
                  photoUrl: ticket.photoUrl ?? sampleIncidents[0].photoUrl,
                  category: ticket.issueCategory,
                  title: ticket.title,
                  gpsCoords: ticket.ward.wardOffice,
                  height: 140,
                  badge: 'Initial Report',
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CivicPhotoRenderer(
                  photoUrl: ticket.followUpPhotoUrl ?? sampleIncidents[0].photoUrl,
                  category: ticket.issueCategory,
                  title: 'Post-Inspection Verification',
                  gpsCoords: ticket.ward.wardOffice,
                  height: 140,
                  badge: 'Field Squad Follow-up',
                  borderRadius: BorderRadius.circular(12),
                  customOverlay: Positioned(
                    bottom: 6,
                    left: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, size: 12, color: CivicColors.primary),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'AI Geo-Tag Verified',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: CivicColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CivicColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded, color: CivicColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('Status History & Timeline', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
            ],
          ),
          const SizedBox(height: 14),
          _buildTimelineStep('Complaint Filed & AI Analyzed', 'Today 2:15 PM', 'Automated computer vision classified severity as High and routed to municipal queue.', isDone: true),
          _buildTimelineStep('Ward & Department Assigned', 'Today 2:20 PM', 'Assigned to Roads & Infrastructure Dept, Ward 4 Central District.', isDone: true),
          _buildTimelineStep('Crew Dispatched', 'In Progress', 'Team Alpha (3 personnel) dispatched from Central Yard. Est. patch completion by 3:00 PM.', isDone: true, isActive: true),
          _buildTimelineStep('Quality Inspection & Closure', 'Pending', 'Final structural check by municipal inspector.', isDone: false),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String title, String time, String desc, {required bool isDone, bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isActive
                  ? CivicColors.primaryContainer
                  : isDone
                      ? CivicColors.primary
                      : CivicColors.outlineVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check : Icons.schedule,
              color: Colors.white,
              size: 13,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isActive ? CivicColors.primary : CivicColors.onSurface)),
                    Text(time, style: const TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentNotes() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CivicColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_outlined, color: CivicColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('Department Notes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.forum_outlined, color: CivicColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Inspection Officer Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: CivicColors.onSurface)),
                      const SizedBox(height: 3),
                      Text(
                        '"${ticket.fieldNotes ?? 'Severe structural base erosion detected beneath surface asphalt layer. High priority cold-patch scheduled.'}"',
                        style: const TextStyle(fontSize: 12, color: CivicColors.onSurfaceVariant, height: 1.35),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Updated by Field Supervisor ${ticket.ward.inspectorName}',
                        style: const TextStyle(fontSize: 10, color: CivicColors.onSurfaceVariant, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SCREEN 5: PROFILE SCREEN
// ==========================================

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onSignOut;
  final VoidCallback? onManagePermissions;

  const ProfileScreen({
    super.key,
    this.onSignOut,
    this.onManagePermissions,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: CivicColors.primary,
            child: const Icon(Icons.person, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 12),
          const Text(
            'Citizen Account (Nehal Kaneria)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
          ),
          const Text(
            'Active Ward: Ward 4 (Navrangpura/Central District, AMC)',
            style: TextStyle(fontSize: 12.5, color: CivicColors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          _buildProfileTile(Icons.notifications_active_outlined, 'SMS / WhatsApp Status Dispatch', 'Enabled (+91 98765 43210)'),
          _buildProfileTile(Icons.location_on_outlined, 'Registered Area', 'Navrangpura CG Road & Vastrapur'),
          _buildProfileTile(Icons.verified_user_outlined, 'Citizen Trust Score', 'Level 4 (Verified Citizen)'),
          _buildProfileTile(Icons.help_outline_rounded, 'AMC Municipal Grievance Helpline', '155304 / 1800 233 2330'),

          if (onManagePermissions != null)
            InkWell(
              onTap: onManagePermissions,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CivicColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: CivicColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security_rounded, color: CivicColors.primary, size: 22),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('System Device Permissions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
                          Text('Camera, GPS Geotag, Storage, and Push Alerts', style: TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: CivicColors.primary),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // App Details & Official App Icon Branding
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CivicColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 48,
                      height: 48,
                      color: CivicColors.primary,
                      child: const Icon(Icons.location_city, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CivicAgent • AMC Civic Issue Agent',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CivicColors.onSurface),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Version 1.0.0+1 • Autonomous Tool Calls & Dispatch',
                        style: TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sign Out Action Button
          if (onSignOut != null)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign Out of CivicAgent?'),
                      content: const Text('You will be returned to the Citizen Sign In portal. Your filed complaints will remain synced with AMC.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onSignOut!();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CivicColors.error,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: CivicColors.error, size: 20),
                label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, color: CivicColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: CivicColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CivicColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: CivicColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CivicColors.onSurface)),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SCREEN 6: SPLASH SCREEN (STITCH INITIALIZER)
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
    return Scaffold(
      backgroundColor: CivicColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Pulsing App Icon Halo
              AnimatedBuilder(
                animation: _animCtrl,
                builder: (context, child) {
                  return Container(
                    padding: EdgeInsets.all(12 + (_animCtrl.value * 6)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CivicColors.primaryContainer.withValues(alpha: 0.15 + (_animCtrl.value * 0.15)),
                    ),
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 96,
                        height: 96,
                        color: CivicColors.primary,
                        child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 48),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

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
                style: TextStyle(
                  fontSize: 14,
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

              const SizedBox(height: 36),

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
                    Text(
                      'Connected to AMC Civic Mesh (Ward 4 GIS)',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: CivicColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

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
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// SCREEN 7: PERMISSIONS ONBOARDING SCREEN
// "allow all permission as per required and necessary"
// ==========================================

class PermissionsScreen extends StatefulWidget {
  final bool cameraGranted;
  final bool locationGranted;
  final bool storageGranted;
  final bool notificationsGranted;
  final Function({
    required bool camera,
    required bool location,
    required bool storage,
    required bool notifications,
  }) onUpdatePermissions;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const PermissionsScreen({
    super.key,
    required this.cameraGranted,
    required this.locationGranted,
    required this.storageGranted,
    required this.notificationsGranted,
    required this.onUpdatePermissions,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  late bool _camera;
  late bool _location;
  late bool _storage;
  late bool _notifications;

  @override
  void initState() {
    super.initState();
    _camera = widget.cameraGranted;
    _location = widget.locationGranted;
    _storage = widget.storageGranted;
    _notifications = widget.notificationsGranted;
  }

  void _notifyChange() {
    widget.onUpdatePermissions(
      camera: _camera,
      location: _location,
      storage: _storage,
      notifications: _notifications,
    );
  }

  void _grantAll() {
    setState(() {
      _camera = true;
      _location = true;
      _storage = true;
      _notifications = true;
    });
    _notifyChange();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ All required permissions granted: Camera, GPS, Media, & Notifications.'),
        backgroundColor: CivicColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _camera && _location && _storage && _notifications;

    return Scaffold(
      backgroundColor: CivicColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: widget.onSkip,
            child: const Text('Skip', style: TextStyle(color: CivicColors.onSurfaceVariant)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CivicColors.primaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.verified_user_rounded, color: CivicColors.primary, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Municipal Device Permissions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: CivicColors.onSurface, letterSpacing: -0.5),
              ),
              const SizedBox(height: 6),
              const Text(
                'CivicAgent requires these system permissions to identify civic hazards, pinpoint your municipal ward, and alert repair squads.',
                style: TextStyle(fontSize: 13, color: CivicColors.onSurfaceVariant, height: 1.4),
              ),
              const SizedBox(height: 20),

              // Master Allow All Permissions Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [CivicColors.primary, CivicColors.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: CivicColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Allow All Required Permissions', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                          SizedBox(height: 2),
                          Text('Recommended for seamless 1-tap complaint filing', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _grantAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: CivicColors.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(allGranted ? 'Granted ✓' : 'Grant All', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Individual Permission Toggles
              _buildPermissionTile(
                icon: Icons.camera_alt_rounded,
                title: 'Camera & Live Reticle',
                subtitle: 'Capture potholes, streetlight fixtures & garbage dumps with real-time HUD analysis.',
                value: _camera,
                onChanged: (v) {
                  setState(() => _camera = v);
                  _notifyChange();
                },
              ),
              _buildPermissionTile(
                icon: Icons.location_on_rounded,
                title: 'Precise GPS Coordinates',
                subtitle: 'Automatically map the exact street location, AMC Ward, and municipal zone.',
                value: _location,
                onChanged: (v) {
                  setState(() => _location = v);
                  _notifyChange();
                },
              ),
              _buildPermissionTile(
                icon: Icons.photo_library_rounded,
                title: 'Photo Gallery & Storage',
                subtitle: 'Attach existing inspection evidence photos from your phone gallery.',
                value: _storage,
                onChanged: (v) {
                  setState(() => _storage = v);
                  _notifyChange();
                },
              ),
              _buildPermissionTile(
                icon: Icons.notifications_active_rounded,
                title: 'Push Notifications & Alerts',
                subtitle: 'Receive real-time notifications on squad dispatch, SLA timers, and resolution.',
                value: _notifications,
                onChanged: (v) {
                  setState(() => _notifications = v);
                  _notifyChange();
                },
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: widget.onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CivicColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Save & Continue to Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: value ? CivicColors.primary.withValues(alpha: 0.3) : CivicColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value ? CivicColors.primaryContainer.withValues(alpha: 0.2) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: value ? CivicColors.primary : Colors.grey, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: CivicColors.onSurface)),
                    const SizedBox(width: 6),
                    if (value)
                      const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: CivicColors.onSurfaceVariant, height: 1.35)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: CivicColors.primary,
            activeThumbColor: Colors.white,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SCREEN 8: CITIZEN SIGN IN SCREEN
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 36,
                        height: 36,
                        color: CivicColors.primary,
                        child: const Icon(Icons.location_city, color: Colors.white, size: 20),
                      ),
                    ),
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
}

// ==========================================
// SCREEN 9: FORGOT PASSWORD SCREEN
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
        child: Padding(
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
// SCREEN 10: OTP VERIFICATION SCREEN
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

              // 6 OTP Box Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
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

// ==========================================
// SCREEN 11: CREW LIVE TRACKING #AMC-9482
// Google Stitch AI Screen: 70e916ecc2784261a0482eb36df4cc03
// ==========================================

class CrewLiveTrackingScreen extends StatelessWidget {
  final CivicTicket ticket;
  final VoidCallback onBack;

  const CrewLiveTrackingScreen({
    super.key,
    required this.ticket,
    required this.onBack,
  });

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
                          Text('Dest: ${ticket.area}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
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
              style: TextStyle(
                fontSize: 12,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: isCurrent ? CivicColors.onSurface : CivicColors.onSurfaceVariant,
              ),
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 11, color: CivicColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _SquadMetric extends StatelessWidget {
  final String label;
  final String value;
  const _SquadMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: CivicColors.onSurface)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10.5, color: CivicColors.onSurfaceVariant)),
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

