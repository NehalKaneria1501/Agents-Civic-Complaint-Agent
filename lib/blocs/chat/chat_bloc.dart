import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/civic_models.dart';
import '../../repositories/civic_repository.dart';
import '../../services/firebase_ai_logic_service.dart';
import '../../services/google_maps_service.dart';
import 'chat_event.dart';
import 'chat_state.dart';

// ==========================================
// BLOC: AI AGENT CHAT BLOC
// Handles conversational municipal diagnostics, Firebase AI Logic,
// Google Maps routing, and live status answers
// ==========================================

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final CivicRepository repository;

  ChatBloc({required this.repository}) : super(const ChatState()) {
    on<LoadInitialChatEvent>(_onLoadInitialChat);
    on<SendChatMessageEvent>(_onSendChatMessage);

    add(const LoadInitialChatEvent());
  }

  Future<void> _onLoadInitialChat(LoadInitialChatEvent event, Emitter<ChatState> emit) async {
    final tickets = await repository.fetchTickets();
    final firstTicket = tickets.isNotEmpty ? tickets.first : null;

    final initialMessages = [
      ChatMessage(
        id: 'user-01',
        isUser: true,
        text: 'Can you report this massive pothole I just hit on Main Street near 4th Ave?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        attachedPhoto: sampleIncidents[0],
      ),
      if (firstTicket != null)
        ChatMessage(
          id: 'bot-01',
          isUser: false,
          text: "I've received your photo. Running automated municipal diagnostics with Firebase AI Logic...",
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          ticketSummary: firstTicket,
          googleMapsUrl: 'https://www.google.com/maps/search/?api=1&query=23.0365,72.5126',
          googleMapsDirectionsUrl: 'https://www.google.com/maps/dir/?api=1&destination=23.0365,72.5126',
          toolCalls: [
            ToolCallLog(
              type: ToolCallType.analyzeImage,
              toolName: 'analyze_civic_image()',
              arguments: {'image': 'pothole_main_st.jpg', 'mode': 'damage_severity'},
              result: {'detected_issue': 'Pothole (severity high)', 'confidence': 0.98},
              latency: const Duration(milliseconds: 480),
            ),
            ToolCallLog(
              type: ToolCallType.firebaseAiLogic,
              toolName: 'firebase_ai_logic.gemini_multimodal_diagnostics()',
              arguments: {'image': 'pothole_main_st.jpg', 'project': 'civic-complaint-agent-dee84'},
              result: {'detected_issue': 'Pothole (severity high)', 'confidence': 0.98},
              latency: const Duration(milliseconds: 480),
            ),
            ToolCallLog(
              type: ToolCallType.googleMapsRoute,
              toolName: 'google_maps_platform.pinpoint_gis()',
              arguments: {'gps': '23.0365, 72.5126', 'destination': 'Main Street & 4th Ave'},
              result: {'ward': 'Ward 4 - Central Zone', 'navigation_url': 'https://maps.google.com/?q=23.0365,72.5126'},
              latency: const Duration(milliseconds: 320),
            ),
            ToolCallLog(
              type: ToolCallType.createTicket,
              toolName: 'create_amc_ticket()',
              arguments: {'title': 'Deep Pothole Hazard', 'ward': 4, 'dept': 'ROAD_ENG'},
              result: {'ticket_id': '#${firstTicket.ticketId}', 'status': 'Assigned', 'sla': '48h'},
              latency: const Duration(milliseconds: 490),
            ),
          ],
        ),
      ChatMessage(
        id: 'user-02',
        isUser: true,
        text: 'What is the status?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      if (firstTicket != null)
        ChatMessage(
          id: 'bot-02',
          isUser: false,
          text: 'Ticket **#${firstTicket.ticketId}** is currently **${firstTicket.status}** with ${firstTicket.department.name}. Estimated repair within ${firstTicket.department.slaHours} hours.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
          ticketSummary: firstTicket,
          googleMapsUrl: 'https://www.google.com/maps/search/?api=1&query=23.0365,72.5126',
          googleMapsDirectionsUrl: 'https://www.google.com/maps/dir/?api=1&destination=23.0365,72.5126',
          toolCalls: [
            ToolCallLog(
              type: ToolCallType.fetchStatus,
              toolName: 'fetch_ticket_status()',
              arguments: {'ticket_id': firstTicket.ticketId},
              result: firstTicket.toJson(),
              latency: const Duration(milliseconds: 310),
            ),
          ],
        ),
    ];

    emit(state.copyWith(messages: initialMessages));
  }

  Future<void> _onSendChatMessage(SendChatMessageEvent event, Emitter<ChatState> emit) async {
    final query = event.text.trim();
    if (query.isEmpty && event.samplePhoto == null) return;

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isUser: true,
      text: query.isNotEmpty ? query : 'Report civic hazard with photo evidence (${event.samplePhoto?.title})',
      timestamp: DateTime.now(),
      attachedPhoto: event.samplePhoto,
    );

    final currentMessages = List<ChatMessage>.from(state.messages)..add(userMsg);
    emit(state.copyWith(
      messages: currentMessages,
      isProcessing: true,
      stepLabel: 'Firebase AI Logic (Gemini) reviewing report...',
    ));

    final lower = query.toLowerCase();
    final isStatus = lower.contains('status') || lower.contains('track') || lower.contains('update');

    if (isStatus && event.samplePhoto == null) {
      final ticket = await repository.searchTicket(query);
      final aiAnswer = await FirebaseAiLogicService.instance.answerQuery(
        query: query,
        currentTicketContext: ticket != null ? 'Ticket #${ticket.ticketId}: ${ticket.title} (${ticket.status})' : null,
      );

      final coords = ticket != null ? GoogleMapsService.parseGpsCoordinates(ticket.area) : null;
      final lat = coords?.key ?? 23.0365;
      final lng = coords?.value ?? 72.5126;

      final botMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        isUser: false,
        text: ticket != null
            ? 'Status for Ticket **#${ticket.ticketId}**: Currently **${ticket.status}** with ${ticket.department.name}. Assigned to ${ticket.ward.wardName}.\n\n$aiAnswer'
            : '$aiAnswer\n\nAll open municipal tickets are monitored on Google Maps in real-time.',
        timestamp: DateTime.now(),
        ticketSummary: ticket,
        googleMapsUrl: 'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
        googleMapsDirectionsUrl: 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
        toolCalls: [
          ToolCallLog(
            type: ToolCallType.fetchStatus,
            toolName: 'fetch_ticket_status()',
            arguments: {'query': query},
            result: ticket?.toJson() ?? {'status': 'No matching ticket'},
            latency: const Duration(milliseconds: 310),
          ),
          ToolCallLog(
            type: ToolCallType.googleMapsRoute,
            toolName: 'google_maps_platform.track_repair_squad()',
            arguments: {'ticket_id': ticket?.ticketId ?? 'AMC-LIVE', 'coords': '$lat,$lng'},
            result: {'maps_active': true, 'destination': '$lat, $lng'},
            latency: const Duration(milliseconds: 240),
          ),
        ],
      );

      final updated = List<ChatMessage>.from(state.messages)..add(botMsg);
      emit(state.copyWith(messages: updated, isProcessing: false, stepLabel: ''));
    } else {
      // Photo or hazard incident diagnostics using Firebase AI Logic
      emit(state.copyWith(stepLabel: 'Firebase AI Logic (Gemini 1.5 Flash) analyzing damage...'));

      final aiResult = await FirebaseAiLogicService.instance.analyzeIncident(
        userText: query,
        samplePhoto: event.samplePhoto,
      );

      emit(state.copyWith(stepLabel: 'Pinpointing Ahmedabad ward & Google Maps GIS...'));
      await Future.delayed(const Duration(milliseconds: 350));

      emit(state.copyWith(stepLabel: 'Registering ticket & dispatching repair squad...'));
      final newTicket = await repository.createTicketFromIncident(
        issueCategory: aiResult.issueCategory,
        description: aiResult.explanation,
        severity: aiResult.severity,
        area: aiResult.area,
        departmentKey: aiResult.departmentKey,
        photoUrl: event.samplePhoto?.photoUrl,
      );

      final botMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        isUser: false,
        text: 'Hazard detected: **${aiResult.title}** (${aiResult.severity} Severity).\n${aiResult.explanation}\n\nAuto-filed Ticket **#${newTicket.ticketId}** to ${newTicket.department.name}. Repair squad alerted with live Google Maps GPS.',
        timestamp: DateTime.now(),
        ticketSummary: newTicket,
        googleMapsUrl: aiResult.googleMapsUrl,
        googleMapsDirectionsUrl: aiResult.googleMapsDirectionsUrl,
        toolCalls: [
          ToolCallLog(
            type: ToolCallType.firebaseAiLogic,
            toolName: 'firebase_ai_logic.multimodal_analyzer()',
            arguments: {'project': 'civic-complaint-agent-dee84', 'model': 'gemini-1.5-flash', 'severity': aiResult.severity},
            result: {'category': aiResult.issueCategory, 'confidence': 0.99, 'live_ai': aiResult.isLiveAi},
            latency: const Duration(milliseconds: 490),
          ),
          ToolCallLog(
            type: ToolCallType.googleMapsRoute,
            toolName: 'google_maps_platform.pinpoint_and_route()',
            arguments: {'gps': '${aiResult.latitude}, ${aiResult.longitude}', 'area': aiResult.area},
            result: {'ward': newTicket.ward.wardName, 'maps_url': aiResult.googleMapsUrl},
            latency: const Duration(milliseconds: 340),
          ),
          ToolCallLog(
            type: ToolCallType.createTicket,
            toolName: 'create_amc_ticket()',
            arguments: {'title': newTicket.title, 'severity': newTicket.severity},
            result: {'ticket_id': '#${newTicket.ticketId}', 'status': 'Assigned', 'sla': '${newTicket.department.slaHours}h'},
            latency: const Duration(milliseconds: 460),
          ),
        ],
      );

      final updated = List<ChatMessage>.from(state.messages)..add(botMsg);
      emit(state.copyWith(messages: updated, isProcessing: false, stepLabel: ''));
    }
  }
}
