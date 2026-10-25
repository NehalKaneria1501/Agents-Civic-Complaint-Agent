import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agentsciviccomplaintagent/repositories/civic_repository.dart';
import 'package:agentsciviccomplaintagent/blocs/profile/profile_cubit.dart';
import 'package:agentsciviccomplaintagent/blocs/tickets/tickets_bloc.dart';
import 'package:agentsciviccomplaintagent/blocs/tickets/tickets_event.dart';
import 'package:agentsciviccomplaintagent/blocs/tickets/tickets_state.dart';
import 'package:agentsciviccomplaintagent/blocs/chat/chat_bloc.dart';
import 'package:agentsciviccomplaintagent/blocs/chat/chat_state.dart';
import 'package:agentsciviccomplaintagent/services/google_maps_service.dart';
import 'package:agentsciviccomplaintagent/services/firebase_ai_logic_service.dart';
import 'package:agentsciviccomplaintagent/services/offline_database_service.dart';
import 'package:agentsciviccomplaintagent/services/sqlite_database_service.dart';
import 'package:agentsciviccomplaintagent/models/civic_models.dart';

void main() {
  group('ProfileCubit (MVVM Citizen ViewModel)', () {
    late ProfileCubit cubit;

    setUp(() {
      cubit = ProfileCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has default citizen details and trust score', () {
      expect(cubit.state.name, 'Nehal Kaneria');
      expect(cubit.state.trustScore, 4);
      expect(cubit.state.photoPath, isNull);
    });

    test('updateProfile modifies specific citizen profile fields', () {
      cubit.updateProfile(
        name: 'Aarav Patel',
        phone: '+91 99999 11111',
        ward: 'Ward 8 (Vastrapur/West District, AMC)',
      );

      expect(cubit.state.name, 'Aarav Patel');
      expect(cubit.state.phone, '+91 99999 11111');
      expect(cubit.state.ward, 'Ward 8 (Vastrapur/West District, AMC)');
      expect(cubit.state.email, 'nehal.kaneria@ahmedabadcity.gov.in'); // Unchanged
    });

    test('updatePhoto and removePhoto updates avatar state correctly', () {
      cubit.updatePhoto('sample_path/avatar.jpg');
      expect(cubit.state.photoPath, 'sample_path/avatar.jpg');

      cubit.removePhoto();
      expect(cubit.state.photoPath, isNull);
    });
  });

  group('TicketsBloc (MVVM Tickets ViewModel)', () {
    late CivicRepository repository;
    late TicketsBloc bloc;

    setUp(() {
      repository = AmcCivicRepository();
      bloc = TicketsBloc(repository: repository);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is TicketsInitialState', () {
      expect(bloc.state, isA<TicketsInitialState>());
    });

    test('LoadTicketsEvent emits TicketsLoadedState with tickets from repository', () async {
      bloc.add(const LoadTicketsEvent());

      await expectLater(
        bloc.stream,
        emits(isA<TicketsLoadedState>().having(
          (s) => s.allTickets.isNotEmpty,
          'allTickets is not empty',
          isTrue,
        )),
      );
    });

    test('FilterTicketsEvent filters tickets by status correctly', () async {
      bloc.add(const LoadTicketsEvent());

      await bloc.stream.firstWhere((s) => s is TicketsLoadedState);

      bloc.add(const FilterTicketsEvent('Resolved'));

      await expectLater(
        bloc.stream,
        emits(isA<TicketsLoadedState>().having(
          (s) => s.activeFilter,
          'activeFilter',
          'Resolved',
        )),
      );
    });
  });

  group('ChatBloc (MVVM Diagnostics & AI Agent ViewModel)', () {
    late CivicRepository repository;
    late ChatBloc chatBloc;

    setUp(() {
      repository = AmcCivicRepository();
      chatBloc = ChatBloc(repository: repository);
    });

    tearDown(() {
      chatBloc.close();
    });

    test('initializes with automated seed municipal chat flow', () async {
      await expectLater(
        chatBloc.stream,
        emits(isA<ChatState>().having(
          (s) => s.messages.isNotEmpty,
          'messages length > 0',
          isTrue,
        )),
      );
    });
  });

  group('GoogleMapsService & FirebaseAiLogicService', () {
    test('parseGpsCoordinates parses degrees and directions accurately', () {
      final coords = GoogleMapsService.parseGpsCoordinates('23.0365° N, 72.5126° E (Ward 4)');
      expect(coords, isNotNull);
      expect(coords!.key, closeTo(23.0365, 0.001));
      expect(coords.value, closeTo(72.5126, 0.001));
    });

    test('parseGpsCoordinates returns Ahmedabad HQ fallback on malformed string', () {
      final coords = GoogleMapsService.parseGpsCoordinates('unknown location');
      expect(coords, isNotNull);
      expect(coords!.key, closeTo(23.0225, 0.001));
      expect(coords.value, closeTo(72.5714, 0.001));
    });

    test('FirebaseAiLogicService analyzeIncident returns valid structured result', () async {
      final result = await FirebaseAiLogicService.instance.analyzeIncident(
        userText: 'Broken asphalt on road',
      );
      expect(result.title, isNotEmpty);
      expect(result.googleMapsUrl, contains('google.com/maps'));
      expect(result.googleMapsDirectionsUrl, contains('google.com/maps/dir'));
      expect(result.latitude, isNotNull);
      expect(result.longitude, isNotNull);
    });
  });

  group('OfflineDatabaseService (Offline-First Local Storage)', () {
    test('OfflineDatabaseService saves and retrieves tickets offline', () async {
      final db = OfflineDatabaseService.instance;
      await db.init();

      final offlineTicket = CivicTicket(
        ticketId: 'AMC-OFFLINE-TEST-1',
        title: 'Offline Water Leakage',
        issueCategory: 'Water & Drainage',
        description: 'Underground pipeline leakage reported offline',
        severity: 'Medium',
        area: 'Paldi Ward 15',
        status: 'Registered',
        createdAt: DateTime.now(),
        ward: const WardInfo(
          wardName: 'Paldi',
          wardNumber: 15,
          zone: 'South-West',
          wardOffice: 'Paldi Sub-Center',
          inspectorName: 'S. K. Mehta',
          phone: '+91 79 2657 0000',
        ),
        department: const DepartmentInfo(
          code: 'DRAINAGE',
          name: 'Water & Sewerage Directorate',
          headOfficer: 'Superintending Engineer',
          slaHours: 12,
          icon: Icons.water_drop_outlined,
        ),
      );

      await db.saveTicket(offlineTicket);
      final tickets = db.getOfflineTickets();

      expect(tickets.any((t) => t.ticketId == 'AMC-OFFLINE-TEST-1'), isTrue);
    });

    test('OfflineDatabaseService queues offline drafts and handles sync', () async {
      final db = OfflineDatabaseService.instance;
      await db.init();

      final draftTicket = CivicTicket(
        ticketId: 'AMC-DRAFT-99',
        title: 'Offline Draft Waste Spillage',
        issueCategory: 'Solid Waste',
        description: 'Bin overflow waiting for internet to sync',
        severity: 'Normal',
        area: 'Ellisbridge Ward 42',
        status: 'Registered',
        createdAt: DateTime.now(),
        ward: const WardInfo(
          wardName: 'Ellisbridge',
          wardNumber: 42,
          zone: 'Central',
          wardOffice: 'Ellisbridge Ward Office',
          inspectorName: 'M. Patel',
          phone: '+91 79 2658 0000',
        ),
        department: const DepartmentInfo(
          code: 'SWM',
          name: 'Solid Waste Management',
          headOfficer: 'Director SWM',
          slaHours: 24,
          icon: Icons.delete_outline_rounded,
        ),
      );

      await db.queueOfflineDraft(draftTicket);
      final pending = db.getPendingDrafts();
      expect(pending.any((d) => d['ticketId'] == 'AMC-DRAFT-99'), isTrue);

      await db.markDraftSynced('AMC-DRAFT-99');
      final pendingAfter = db.getPendingDrafts();
      expect(pendingAfter.any((d) => d['ticketId'] == 'AMC-DRAFT-99'), isFalse);
    });
  });

  group('SqliteDatabaseService (Relational Engine & Persistence)', () {
    test('SqliteDatabaseService initializes, inserts, queries, and updates tickets', () async {
      final sqlite = SqliteDatabaseService.instance;
      await sqlite.init();

      final sqliteTicket = CivicTicket(
        ticketId: 'SQLITE-TICKET-01',
        title: 'Water Main Burst (SQLite)',
        issueCategory: 'Drainage & Storm Floods',
        description: 'Underground pipeline rupture causing waterlogging on road',
        severity: 'Critical',
        area: 'Paldi Cross Road, Ward 15',
        status: 'Assigned',
        createdAt: DateTime.now(),
        ward: const WardInfo(
          wardName: 'Paldi',
          wardNumber: 15,
          zone: 'West Zone',
          wardOffice: 'Paldi Sub-Office',
          inspectorName: 'S. Mehta',
          phone: '+91 79 2657 1122',
        ),
        department: const DepartmentInfo(
          code: 'DRAINAGE',
          name: 'Drainage & Water Supply',
          headOfficer: 'Superintending Engineer',
          slaHours: 12,
          icon: Icons.water_drop_outlined,
        ),
      );

      await sqlite.insertTicket(sqliteTicket);
      final queryAll = sqlite.queryTickets();
      expect(queryAll.any((t) => t.ticketId == 'SQLITE-TICKET-01'), isTrue);

      final searchResult = sqlite.queryTickets(searchQuery: 'Paldi');
      expect(searchResult.any((t) => t.ticketId == 'SQLITE-TICKET-01'), isTrue);

      final updated = await sqlite.updateTicketStatus('SQLITE-TICKET-01', 'In Progress', notes: 'Repair crew on site');
      expect(updated, isTrue);

      final updatedTicket = sqlite.queryTickets().firstWhere((t) => t.ticketId == 'SQLITE-TICKET-01');
      expect(updatedTicket.status, 'In Progress');
      expect(updatedTicket.fieldNotes, 'Repair crew on site');
    });

    test('SqliteDatabaseService queues drafts, manages citizen profile and audit logs', () async {
      final sqlite = SqliteDatabaseService.instance;
      await sqlite.init();

      final draftTicket = CivicTicket(
        ticketId: 'SQLITE-DRAFT-02',
        title: 'Broken Manhole Cover',
        issueCategory: 'Pothole',
        description: 'Dangerous opening on pedestrian path',
        severity: 'High',
        area: 'Navrangpura Ward 10',
        status: 'Registered',
        createdAt: DateTime.now(),
        ward: const WardInfo(
          wardName: 'Navrangpura',
          wardNumber: 10,
          zone: 'West Zone',
          wardOffice: 'Navrangpura Ward Office',
          inspectorName: 'R. Shah',
          phone: '+91 79 2656 4455',
        ),
        department: const DepartmentInfo(
          code: 'ROAD_ENG',
          name: 'Roads & Infrastructure',
          headOfficer: 'City Engineer',
          slaHours: 24,
          icon: Icons.car_crash_rounded,
        ),
      );

      await sqlite.queueDraft(draftTicket);
      final pendingDrafts = sqlite.queryPendingDrafts();
      expect(pendingDrafts.any((d) => d['ticket_id'] == 'SQLITE-DRAFT-02'), isTrue);

      await sqlite.markDraftSynced('SQLITE-DRAFT-02');
      final remainingDrafts = sqlite.queryPendingDrafts();
      expect(remainingDrafts.any((d) => d['ticket_id'] == 'SQLITE-DRAFT-02'), isFalse);

      // Citizen profile
      await sqlite.saveProfile({
        'name': 'Priya Patel',
        'email': 'priya.patel@amc.gov.in',
        'ward': 'Ward 10 - Navrangpura',
      });
      final profile = sqlite.getProfile();
      expect(profile?['name'], 'Priya Patel');

      // Audit logs
      final logs = sqlite.getAuditLogs();
      expect(logs.isNotEmpty, isTrue);
    });
  });
}

