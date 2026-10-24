import 'dart:async';
import '../models/civic_models.dart';
import '../services/amc_database.dart';
import '../services/firestore_service.dart';

// ==========================================
// MVVM REPOSITORY PATTERN: CIVIC REPOSITORY
// Single source of truth for tickets and municipal operations
// ==========================================

abstract class CivicRepository {
  Future<List<CivicTicket>> fetchTickets();
  Future<CivicTicket> registerTicket(CivicTicket ticket);
  Future<CivicTicket> createTicketFromIncident({
    required String issueCategory,
    required String description,
    required String severity,
    required String area,
    required String departmentKey,
    String? photoUrl,
    String? followUpPhotoUrl,
  });
  Future<void> advanceTicketStatus(CivicTicket ticket);
  Future<void> escalateTicket(CivicTicket ticket);
  Future<CivicTicket?> searchTicket(String query);
  Stream<List<CivicTicket>> get ticketsStream;
}

class AmcCivicRepository implements CivicRepository {
  final AmcDatabase _database;
  final FirestoreService _firestore;
  final _ticketsStreamController = StreamController<List<CivicTicket>>.broadcast();

  AmcCivicRepository({
    AmcDatabase? database,
    FirestoreService? firestore,
  })  : _database = database ?? AmcDatabase.instance,
        _firestore = firestore ?? FirestoreService.instance {
    _broadcastCurrentTickets();
  }

  void _broadcastCurrentTickets() {
    _ticketsStreamController.add(List.unmodifiable(_database.tickets));
  }

  @override
  Stream<List<CivicTicket>> get ticketsStream => _ticketsStreamController.stream;

  @override
  Future<List<CivicTicket>> fetchTickets() async {
    return List.unmodifiable(_database.tickets);
  }

  @override
  Future<CivicTicket> registerTicket(CivicTicket ticket) async {
    _database.addTicket(ticket);
    await _firestore.saveTicket(ticket);
    _broadcastCurrentTickets();
    return ticket;
  }

  @override
  Future<CivicTicket> createTicketFromIncident({
    required String issueCategory,
    required String description,
    required String severity,
    required String area,
    required String departmentKey,
    String? photoUrl,
    String? followUpPhotoUrl,
  }) async {
    final ticket = _database.createTicket(
      issueCategory: issueCategory,
      description: description,
      severity: severity,
      area: area,
      departmentKey: departmentKey,
      photoUrl: photoUrl,
      followUpPhotoUrl: followUpPhotoUrl,
    );
    _broadcastCurrentTickets();
    return ticket;
  }

  @override
  Future<void> advanceTicketStatus(CivicTicket ticket) async {
    _database.advanceTicketStatus(ticket);
    _broadcastCurrentTickets();
  }

  @override
  Future<void> escalateTicket(CivicTicket ticket) async {
    ticket.isEscalated = true;
    _database.updateTicketStatus(ticket.ticketId, ticket.status, notes: '⚠️ Escalated to Zonal Chief Engineer');
    _broadcastCurrentTickets();
  }

  @override
  Future<CivicTicket?> searchTicket(String query) async {
    return _database.fetchStatus(query);
  }

  void dispose() {
    _ticketsStreamController.close();
  }
}
