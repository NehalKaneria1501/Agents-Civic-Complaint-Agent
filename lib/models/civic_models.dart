import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/civic_colors.dart';

// ==========================================
// MUNICIPAL DATA MODELS
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

  Map<String, dynamic> toJson() => {
    'ward_name': wardName,
    'ward_number': wardNumber,
    'zone': zone,
    'ward_office': wardOffice,
    'inspector_name': inspectorName,
    'phone': phone,
  };

  factory WardInfo.fromJson(Map<String, dynamic> json) => WardInfo(
    wardName: json['ward_name'] ?? 'Ward 4 - Central Zone',
    wardNumber: json['ward_number'] ?? 4,
    zone: json['zone'] ?? 'Central Zone',
    wardOffice: json['ward_office'] ?? 'AMC Central Complex',
    inspectorName: json['inspector_name'] ?? 'Municipal Inspector',
    phone: json['phone'] ?? '+91 79 2535 2821',
  );
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

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'head_officer': headOfficer,
    'sla_hours': slaHours,
  };

  factory DepartmentInfo.fromJson(Map<String, dynamic> json) => DepartmentInfo(
    code: json['code'] ?? 'ROAD_ENG',
    name: json['name'] ?? 'Roads & Infrastructure Dept',
    headOfficer: json['head_officer'] ?? 'City Engineer',
    slaHours: json['sla_hours'] ?? 48,
    icon: Icons.car_crash_rounded,
  );
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
    'photo_url': photoUrl,
    'follow_up_photo_url': followUpPhotoUrl,
  };

  factory CivicTicket.fromJson(Map<String, dynamic> json, {WardInfo? fallbackWard, DepartmentInfo? fallbackDept}) {
    return CivicTicket(
      ticketId: json['ticket_id'] ?? 'AMC-${DateTime.now().millisecondsSinceEpoch % 10000}',
      title: json['title'] ?? 'Civic Issue',
      issueCategory: json['category'] ?? 'Road & Asphalt',
      description: json['description'] ?? 'Municipal report',
      severity: json['severity'] ?? 'High',
      area: json['area'] ?? 'Ahmedabad Municipal Area',
      ward: fallbackWard ?? WardInfo.fromJson(json),
      department: fallbackDept ?? DepartmentInfo.fromJson(json),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) ?? DateTime.now() : DateTime.now(),
      status: json['status'] ?? 'Registered',
      fieldNotes: json['field_notes'],
      squadId: json['squad_id'],
      photoUrl: json['photo_url'],
      followUpPhotoUrl: json['follow_up_photo_url'],
      depthCm: json['depth_cm'] ?? 15,
      isEscalated: json['is_escalated'] ?? false,
    );
  }
}

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

// Helper for Camera & Gallery Picking
Future<SampleIncident?> pickCivicPhoto({
  required BuildContext context,
  required ImageSource source,
  SampleIncident? categoryTemplate,
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
    final template = categoryTemplate ?? sampleIncidents[0];

    return SampleIncident(
      key: 'user-${DateTime.now().millisecondsSinceEpoch}',
      title: '${template.title} (${isCamera ? "Camera" : "Gallery"})',
      issueCategory: template.issueCategory,
      defaultArea: template.defaultArea,
      description: 'Reported with photographic evidence captured via user device (${isCamera ? "Camera" : "Gallery"}).',
      severity: template.severity,
      departmentKey: template.departmentKey,
      icon: isCamera ? Icons.photo_camera_rounded : Icons.photo_library_rounded,
      accentColor: template.accentColor,
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
// AGENT TOOL CALL & CHAT MODELS
// ==========================================

enum ToolCallType {
  analyzeImage,
  lookupWardDepartment,
  createTicket,
  fetchStatus,
  googleMapsRoute,
  firebaseAiLogic,
}

class ToolCallLog {
  final ToolCallType type;
  final String toolName;
  final Map<String, dynamic> arguments;
  final Map<String, dynamic> result;
  final Duration latency;

  ToolCallLog({
    required this.type,
    required this.toolName,
    required this.arguments,
    required this.result,
    required this.latency,
  });
}

class ChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final DateTime timestamp;
  final SampleIncident? attachedPhoto;
  final CivicTicket? ticketSummary;
  final List<ToolCallLog> toolCalls;
  final String? googleMapsUrl;
  final String? googleMapsDirectionsUrl;

  ChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.timestamp,
    this.attachedPhoto,
    this.ticketSummary,
    this.toolCalls = const [],
    this.googleMapsUrl,
    this.googleMapsDirectionsUrl,
  });
}
