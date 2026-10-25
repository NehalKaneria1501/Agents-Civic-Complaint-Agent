import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/civic_models.dart';

// ==========================================
// OFFLINE CIVIC DATABASE SERVICE
// Persistent Local Storage & Offline-First Ledger
// Saves tickets, drafts, and citizen data locally
// Works 100% offline with zero external native dependencies
// ==========================================

class OfflineDatabaseService {
  static final OfflineDatabaseService instance = OfflineDatabaseService._internal();
  OfflineDatabaseService._internal();

  bool _isInitialized = false;
  final Map<String, dynamic> _memoryCache = {
    'tickets': <Map<String, dynamic>>[],
    'offline_drafts': <Map<String, dynamic>>[],
    'citizen_profile': <String, dynamic>{},
    'settings': <String, dynamic>{},
    'last_sync_timestamp': null,
  };

  File? _dbFile;

  /// Initializes the offline database and restores cached data from disk
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      // Locate persistent storage path
      final dir = await _resolveStorageDirectory();
      if (dir != null) {
        _dbFile = File('${dir.path}/amc_offline_civic_db.json');
        if (await _dbFile!.exists()) {
          final content = await _dbFile!.readAsString();
          if (content.isNotEmpty) {
            final parsed = jsonDecode(content) as Map<String, dynamic>;
            _memoryCache['tickets'] = parsed['tickets'] ?? [];
            _memoryCache['offline_drafts'] = parsed['offline_drafts'] ?? [];
            _memoryCache['citizen_profile'] = parsed['citizen_profile'] ?? {};
            _memoryCache['settings'] = parsed['settings'] ?? {};
            _memoryCache['last_sync_timestamp'] = parsed['last_sync_timestamp'];
            debugPrint('✓ OfflineDatabase loaded ${_memoryCache['tickets'].length} tickets from ${_dbFile!.path}');
          }
        } else {
          await _flushToDisk();
        }
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('! OfflineDatabase init notice: $e (using in-memory offline fallback)');
      _isInitialized = true;
    }
  }

  Future<Directory?> _resolveStorageDirectory() async {
    try {
      if (kIsWeb) return null;
      // Use system temp or current working directory on desktop/mobile
      final envPath = Platform.environment['APPDATA'] ??
          Platform.environment['LOCALAPPDATA'] ??
          Platform.environment['HOME'];
      if (envPath != null && Directory(envPath).existsSync()) {
        final target = Directory('$envPath/AmcCivicComplaintAgent');
        if (!target.existsSync()) {
          target.createSync(recursive: true);
        }
        return target;
      }
      return Directory.systemTemp;
    } catch (_) {
      return Directory.systemTemp;
    }
  }

  Future<void> _flushToDisk() async {
    try {
      if (_dbFile != null) {
        final raw = jsonEncode(_memoryCache);
        await _dbFile!.writeAsString(raw, flush: true);
      }
    } catch (e) {
      debugPrint('! OfflineDatabase disk write warning: $e');
    }
  }

  // --- 1. TICKET PERSISTENCE ---

  /// Saves or updates a ticket in local offline storage
  Future<void> saveTicket(CivicTicket ticket) async {
    await init();
    final list = List<Map<String, dynamic>>.from(_memoryCache['tickets'] ?? []);
    final map = _ticketToMap(ticket);

    final idx = list.indexWhere((m) => m['ticketId'] == ticket.ticketId);
    if (idx >= 0) {
      list[idx] = map;
    } else {
      list.insert(0, map);
    }

    _memoryCache['tickets'] = list;
    await _flushToDisk();
    debugPrint('✓ Ticket #${ticket.ticketId} saved to offline database');
  }

  /// Saves a list of tickets into offline cache
  Future<void> saveAllTickets(List<CivicTicket> tickets) async {
    await init();
    final list = tickets.map((t) => _ticketToMap(t)).toList();
    _memoryCache['tickets'] = list;
    await _flushToDisk();
  }

  /// Retrieves all offline cached tickets
  List<CivicTicket> getOfflineTickets() {
    try {
      final list = _memoryCache['tickets'] as List<dynamic>? ?? [];
      return list.map((m) => _mapToTicket(Map<String, dynamic>.from(m as Map))).toList();
    } catch (e) {
      debugPrint('! Error reading offline tickets: $e');
      return [];
    }
  }

  // --- 2. OFFLINE GRIEVANCE QUEUE (Drafts waiting for internet) ---

  /// Stores a complaint queued while citizen is completely offline
  Future<void> queueOfflineDraft(CivicTicket draft) async {
    await init();
    final drafts = List<Map<String, dynamic>>.from(_memoryCache['offline_drafts'] ?? []);
    final map = _ticketToMap(draft);
    map['queuedAt'] = DateTime.now().toIso8601String();
    drafts.insert(0, map);
    _memoryCache['offline_drafts'] = drafts;

    // Also add to tickets ledger so citizen sees it immediately
    await saveTicket(draft);
    await _flushToDisk();
    debugPrint('✓ Offline draft queued for Ticket #${draft.ticketId}');
  }

  /// Gets list of offline complaints waiting for sync
  List<Map<String, dynamic>> getPendingDrafts() {
    return List<Map<String, dynamic>>.from(_memoryCache['offline_drafts'] ?? []);
  }

  /// Removes a draft once synced with Cloud Firestore
  Future<void> markDraftSynced(String ticketId) async {
    final drafts = List<Map<String, dynamic>>.from(_memoryCache['offline_drafts'] ?? []);
    drafts.removeWhere((d) => d['ticketId'] == ticketId);
    _memoryCache['offline_drafts'] = drafts;
    _memoryCache['last_sync_timestamp'] = DateTime.now().toIso8601String();
    await _flushToDisk();
    debugPrint('✓ Draft #$ticketId marked synced in offline database');
  }

  // --- 3. CITIZEN PROFILE & SETTINGS ---

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    await init();
    _memoryCache['citizen_profile'] = profile;
    await _flushToDisk();
  }

  Map<String, dynamic> getProfile() {
    return Map<String, dynamic>.from(_memoryCache['citizen_profile'] as Map? ?? {});
  }

  Future<void> saveSetting(String key, dynamic value) async {
    await init();
    final settings = Map<String, dynamic>.from(_memoryCache['settings'] as Map? ?? {});
    settings[key] = value;
    _memoryCache['settings'] = settings;
    await _flushToDisk();
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    final settings = _memoryCache['settings'] as Map? ?? {};
    return settings[key] ?? defaultValue;
  }

  // --- 4. SERIALIZATION HELPERS ---

  Map<String, dynamic> _ticketToMap(CivicTicket t) {
    return {
      'ticketId': t.ticketId,
      'title': t.title,
      'issueCategory': t.issueCategory,
      'description': t.description,
      'severity': t.severity,
      'area': t.area,
      'status': t.status,
      'fieldNotes': t.fieldNotes,
      'squadId': t.squadId,
      'photoUrl': t.photoUrl,
      'followUpPhotoUrl': t.followUpPhotoUrl,
      'createdAt': t.createdAt.toIso8601String(),
      'depthCm': t.depthCm,
      'isEscalated': t.isEscalated,
      'ward': {
        'wardName': t.ward.wardName,
        'wardNumber': t.ward.wardNumber,
        'zone': t.ward.zone,
        'wardOffice': t.ward.wardOffice,
        'inspectorName': t.ward.inspectorName,
        'phone': t.ward.phone,
      },
      'department': {
        'code': t.department.code,
        'name': t.department.name,
        'headOfficer': t.department.headOfficer,
        'slaHours': t.department.slaHours,
      },
    };
  }

  CivicTicket _mapToTicket(Map<String, dynamic> m) {
    final wardMap = m['ward'] as Map<String, dynamic>? ?? {};
    final deptMap = m['department'] as Map<String, dynamic>? ?? {};

    return CivicTicket(
      ticketId: m['ticketId'] ?? 'AMC-OFFLINE',
      title: m['title'] ?? 'Civic Issue',
      issueCategory: m['issueCategory'] ?? 'Civic Issue',
      description: m['description'] ?? '',
      severity: m['severity'] ?? 'Normal',
      area: m['area'] ?? 'Ahmedabad Ward',
      status: m['status'] ?? 'Registered',
      fieldNotes: m['fieldNotes'],
      squadId: m['squadId'],
      photoUrl: m['photoUrl'],
      followUpPhotoUrl: m['followUpPhotoUrl'],
      createdAt: m['createdAt'] != null ? DateTime.tryParse(m['createdAt']) ?? DateTime.now() : DateTime.now(),
      depthCm: (m['depthCm'] as num?)?.toInt() ?? 15,
      isEscalated: m['isEscalated'] ?? false,
      ward: WardInfo(
        wardName: wardMap['wardName'] ?? 'Ward 4 - Central Zone',
        wardNumber: wardMap['wardNumber'] ?? 4,
        zone: wardMap['zone'] ?? 'Central Zone',
        wardOffice: wardMap['wardOffice'] ?? 'AMC Central HQ',
        inspectorName: wardMap['inspectorName'] ?? 'Ward Inspector',
        phone: wardMap['phone'] ?? '+91 79 2535 2821',
      ),
      department: DepartmentInfo(
        code: deptMap['code'] ?? 'ROAD_ENG',
        name: deptMap['name'] ?? 'Roads & Infrastructure Dept',
        headOfficer: deptMap['headOfficer'] ?? 'City Engineer',
        slaHours: deptMap['slaHours'] ?? 24,
        icon: Icons.location_city_rounded,
      ),
    );
  }
}
