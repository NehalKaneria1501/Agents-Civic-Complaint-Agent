import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/civic_models.dart';

// ==========================================
// CLOUD FIRESTORE SERVICE (civic-complaint-agent-dee84)
// Stores and syncs municipal complaints in Firestore:
// Path: /Agents: Civic Complaint Agent/Agents: Civic Complaint Agent
// ==========================================

class FirestoreService {
  static final FirestoreService instance = FirestoreService._internal();
  FirestoreService._internal();

  FirebaseFirestore? _firestore;
  bool _isInitialized = false;

  static const String mainCollection = 'Agents: Civic Complaint Agent';
  static const String mainDocId = 'Agents: Civic Complaint Agent';

  void init() {
    try {
      _firestore = FirebaseFirestore.instance;
      _isInitialized = true;
      debugPrint('✓ FirestoreService connected to civic-complaint-agent-dee84');
      syncInitialData();
    } catch (e) {
      debugPrint('! FirestoreService init warning: $e');
    }
  }

  DocumentReference<Map<String, dynamic>>? get _mainDocRef {
    if (!_isInitialized || _firestore == null) {
      init();
    }
    return _firestore?.collection(mainCollection).doc(mainDocId);
  }

  CollectionReference<Map<String, dynamic>>? get _ticketsSubCollectionRef {
    return _mainDocRef?.collection('tickets');
  }

  CollectionReference<Map<String, dynamic>>? get _rootTicketsRef {
    return _firestore?.collection('tickets');
  }

  /// Initial sync to populate the database upon app start
  Future<void> syncInitialData() async {
    try {
      final docRef = _mainDocRef;
      if (docRef == null) return;

      final now = DateTime.now().toIso8601String();
      await docRef.set({
        'agent_name': 'Civic Complaint Agent',
        'city': 'Ahmedabad',
        'corporation': 'Ahmedabad Municipal Corporation (AMC)',
        'portal_url': 'https://console.firebase.google.com/u/0/project/civic-complaint-agent-dee84/firestore',
        'status': 'Online & Auto-routing Active',
        'last_synced_at': now,
        'ward_zone': 'Central Zone (Ward 4 - Navrangpura/Danapith)',
        'sla_resolution_rate': '94.8%',
        'total_tickets_logged': 4,
        'active_tickets_count': 3,
        'supported_departments': [
          'Roads & Infrastructure',
          'Solid Waste Management',
          'Street Lighting & Electrical',
          'Water Supply & Sewerage',
        ],
      }, SetOptions(merge: true));

      debugPrint('✓ Main Firestore document synced: /Agents: Civic Complaint Agent/Agents: Civic Complaint Agent');
    } catch (e) {
      debugPrint('! Firestore syncInitialData error: $e');
    }
  }

  /// Save or update a CivicTicket in Firestore across both paths
  Future<bool> saveTicket(CivicTicket ticket) async {
    try {
      final data = ticket.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      // 1. Save in main agent subcollection
      final subRef = _ticketsSubCollectionRef;
      if (subRef != null) {
        await subRef.doc(ticket.ticketId).set(data, SetOptions(merge: true));
      }

      // 2. Also save in root tickets collection for fast indexing
      final rootRef = _rootTicketsRef;
      if (rootRef != null) {
        await rootRef.doc(ticket.ticketId).set(data, SetOptions(merge: true));
      }

      // 3. Update main summary doc
      final docRef = _mainDocRef;
      if (docRef != null) {
        await docRef.set({
          'last_synced_at': DateTime.now().toIso8601String(),
          'recent_ticket_id': ticket.ticketId,
          'recent_ticket_title': ticket.title,
          'recent_ticket_status': ticket.status,
        }, SetOptions(merge: true));
      }

      debugPrint('✓ Ticket #${ticket.ticketId} successfully stored in Firestore: $mainCollection/$mainDocId');
      return true;
    } catch (e) {
      debugPrint('! Firestore saveTicket error: $e');
      return false;
    }
  }

  /// Fetch all tickets from Firestore
  Future<List<CivicTicket>> fetchTickets() async {
    try {
      final subRef = _ticketsSubCollectionRef;
      if (subRef == null) return [];

      final snapshot = await subRef.orderBy('created_at', descending: true).get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => CivicTicket.fromJson(doc.data())).toList();
      }

      final rootRef = _rootTicketsRef;
      if (rootRef != null) {
        final rootSnap = await rootRef.orderBy('created_at', descending: true).get();
        return rootSnap.docs.map((doc) => CivicTicket.fromJson(doc.data())).toList();
      }

      return [];
    } catch (e) {
      debugPrint('! Firestore fetchTickets error: $e');
      return [];
    }
  }

  /// Real-time stream of tickets from Firestore
  Stream<List<CivicTicket>> streamTickets() {
    final subRef = _ticketsSubCollectionRef;
    if (subRef == null) return const Stream.empty();

    return subRef.orderBy('created_at', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CivicTicket.fromJson(doc.data())).toList();
    });
  }

  /// Update ticket status in Firestore
  Future<bool> updateStatus(String ticketId, String newStatus, {String? notes}) async {
    try {
      final updateData = <String, dynamic>{
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (notes != null) {
        updateData['field_notes'] = notes;
      }

      final subRef = _ticketsSubCollectionRef;
      if (subRef != null) {
        await subRef.doc(ticketId).update(updateData);
      }

      final rootRef = _rootTicketsRef;
      if (rootRef != null) {
        await rootRef.doc(ticketId).update(updateData);
      }

      return true;
    } catch (e) {
      debugPrint('! Firestore updateStatus error: $e');
      return false;
    }
  }
}
