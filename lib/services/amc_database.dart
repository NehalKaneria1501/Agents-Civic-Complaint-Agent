import 'package:flutter/material.dart';
import '../models/civic_models.dart';
import 'firestore_service.dart';

// ==========================================
// REACTIVE AMC DATABASE & MUNICIPAL LEDGER
// Syncs local reactive state with Cloud Firestore
// ==========================================

class AmcDatabase {
  static final AmcDatabase instance = AmcDatabase._internal();
  AmcDatabase._internal() {
    _seedInitialTickets();
    _syncWithFirestore();
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
        issueCategory: 'Garbage',
        description: 'Commercial vegetable waste spillage choking pedestrian curb',
        severity: 'Medium',
        area: 'Vastrapur Market Sq.',
        ward: wardRegistry['vastrapur']!,
        department: departments['garbage']!,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        status: 'Resolved',
        fieldNotes: 'Compactor vehicle cleared bin; street washed.',
        squadId: 'SQUAD-SWM-01',
      ),
    );
  }

  void _syncWithFirestore() async {
    try {
      // Sync initial seeded tickets to Firestore in background
      for (final t in tickets) {
        FirestoreService.instance.saveTicket(t);
      }
    } catch (_) {}
  }

  WardInfo findWard(String locationQuery) {
    final q = locationQuery.toLowerCase();
    for (final entry in wardRegistry.entries) {
      if (q.contains(entry.key) || q.contains(entry.value.wardName.toLowerCase())) {
        return entry.value;
      }
    }
    return wardRegistry['ward 4']!;
  }

  DepartmentInfo findDepartment(String categoryOrDeptKey) {
    final k = categoryOrDeptKey.toLowerCase();
    if (k.contains('pothole') || k.contains('road') || k.contains('asphalt')) {
      return departments['pothole']!;
    } else if (k.contains('garbage') || k.contains('waste') || k.contains('dump') || k.contains('clean')) {
      return departments['garbage']!;
    } else if (k.contains('street') || k.contains('light') || k.contains('lamp')) {
      return departments['streetlight']!;
    } else if (k.contains('water') || k.contains('drain') || k.contains('flood') || k.contains('monsoon')) {
      return departments['waterlogging']!;
    }
    return departments['pothole']!;
  }

  CivicTicket createTicket({
    required String issueCategory,
    required String description,
    required String severity,
    required String area,
    required String departmentKey,
    String? photoUrl,
    String? followUpPhotoUrl,
  }) {
    final randomNum = 1000 + (DateTime.now().millisecondsSinceEpoch % 8999);
    final ticketId = 'AMC-$randomNum';
    final ward = findWard(area);
    final department = findDepartment(departmentKey);

    final newTicket = CivicTicket(
      ticketId: ticketId,
      title: '$issueCategory Hazard',
      issueCategory: issueCategory,
      description: description,
      severity: severity,
      area: area.isNotEmpty ? area : '${ward.wardName} (${ward.zone})',
      ward: ward,
      department: department,
      createdAt: DateTime.now(),
      status: 'Assigned',
      fieldNotes: 'Auto-triaged by Civic AI Agent to ${department.name}. Crew alert dispatched.',
      squadId: 'SQUAD-WZ-04',
      photoUrl: photoUrl,
      followUpPhotoUrl: followUpPhotoUrl,
      depthCm: severity == 'Critical' ? 24 : 14,
    );

    tickets.insert(0, newTicket);

    // Persist to Cloud Firestore (civic-complaint-agent-dee84)
    FirestoreService.instance.saveTicket(newTicket);

    return newTicket;
  }

  void addTicket(CivicTicket ticket) {
    tickets.insert(0, ticket);
    FirestoreService.instance.saveTicket(ticket);
  }

  CivicTicket? fetchStatus(String query) {
    final q = query.trim().toUpperCase();
    for (final ticket in tickets) {
      if (q.contains(ticket.ticketId)) {
        return ticket;
      }
    }
    return tickets.first;
  }

  void advanceTicketStatus(CivicTicket ticket) {
    if (ticket.status == 'Registered') {
      ticket.status = 'Assigned';
    } else if (ticket.status == 'Assigned') {
      ticket.status = 'In Progress';
    } else if (ticket.status == 'In Progress') {
      ticket.status = 'Resolved';
    } else {
      ticket.status = 'Assigned';
    }
    FirestoreService.instance.updateStatus(ticket.ticketId, ticket.status, notes: ticket.fieldNotes);
  }

  void updateTicketStatus(String ticketId, String newStatus, {String? notes}) {
    for (final t in tickets) {
      if (t.ticketId == ticketId) {
        t.status = newStatus;
        if (notes != null) t.fieldNotes = notes;
        FirestoreService.instance.updateStatus(ticketId, newStatus, notes: notes);
        break;
      }
    }
  }
}

