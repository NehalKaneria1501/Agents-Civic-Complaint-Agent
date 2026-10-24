import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/civic_models.dart';
import '../../repositories/civic_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

// ==========================================
// BLOC: AI AGENT CHAT BLOC
// Handles conversational municipal diagnostics, tool calling, and live status answers
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
          text: "I've received your photo. Running automated municipal diagnostics...",
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          ticketSummary: firstTicket,
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
              result: {'ticket_id': '#${firstTicket.ticketId}', 'status': 'Assigned', 'sla': '48h'},
              latency: const Duration(milliseconds: 520),
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
          toolCalls: [
            ToolCallLog(
              type: ToolCallType.fetchStatus,
              toolName: 'fetch_ticket_status()',
              arguments: {'ticket_id': firstTicket.ticketId},
              result: firstTicket.toJson(),
              latency: const Duration(milliseconds: 320),
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
      stepLabel: 'CivicBot reviewing municipal query...',
    ));

    final lower = query.toLowerCase();
    final isStatus = lower.contains('status') || lower.contains('track') || lower.contains('update');

    if (isStatus && event.samplePhoto == null) {
      final ticket = await repository.searchTicket(query);
      await Future.delayed(const Duration(milliseconds: 650));

      final botMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        isUser: false,
        text: ticket != null
            ? 'Status for Ticket **#${ticket.ticketId}**: Currently **${ticket.status}** with ${ticket.department.name}. Assigned to ${ticket.ward.wardName}.'
            : 'I checked the municipal ledger. All open tickets for your ward are under active inspection.',
        timestamp: DateTime.now(),
        ticketSummary: ticket,
        toolCalls: [
          ToolCallLog(
            type: ToolCallType.fetchStatus,
            toolName: 'fetch_ticket_status()',
            arguments: {'query': query},
            result: ticket?.toJson() ?? {'status': 'No matching ticket'},
            latency: const Duration(milliseconds: 310),
          ),
        ],
      );

      final updated = List<ChatMessage>.from(state.messages)..add(botMsg);
      emit(state.copyWith(messages: updated, isProcessing: false, stepLabel: ''));
    } else {
      // Photo incident diagnostics
      final incident = event.samplePhoto ?? sampleIncidents[0];

      emit(state.copyWith(stepLabel: 'Running AI computer vision damage analysis...'));
      await Future.delayed(const Duration(milliseconds: 500));

      emit(state.copyWith(stepLabel: 'Pinpointing AMC Ward & GIS cadastral map...'));
      await Future.delayed(const Duration(milliseconds: 400));

      emit(state.copyWith(stepLabel: 'Registering ticket & dispatching repair squad...'));
      final newTicket = await repository.createTicketFromIncident(
        issueCategory: incident.issueCategory,
        description: incident.description,
        severity: incident.severity,
        area: incident.defaultArea,
        departmentKey: incident.departmentKey,
        photoUrl: incident.photoUrl,
      );

      final botMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        isUser: false,
        text: 'Hazard detected: **${incident.title}** (${incident.severity} Severity). Auto-filed Ticket **#${newTicket.ticketId}** to ${newTicket.department.name}. Repair squad alerted with live GPS.',
        timestamp: DateTime.now(),
        ticketSummary: newTicket,
        toolCalls: [
          ToolCallLog(
            type: ToolCallType.analyzeImage,
            toolName: 'analyze_civic_image()',
            arguments: {'image': incident.photoUrl, 'mode': 'damage_severity'},
            result: {'detected_issue': incident.title, 'severity': incident.severity, 'confidence': 0.99},
            latency: const Duration(milliseconds: 460),
          ),
          ToolCallLog(
            type: ToolCallType.lookupWardDepartment,
            toolName: 'lookup_ward_and_department()',
            arguments: {'gps': incident.gpsCoords, 'issue': incident.title},
            result: {'ward': newTicket.ward.wardName, 'dept': newTicket.department.name},
            latency: const Duration(milliseconds: 380),
          ),
          ToolCallLog(
            type: ToolCallType.createTicket,
            toolName: 'create_amc_ticket()',
            arguments: {'title': newTicket.title, 'severity': newTicket.severity},
            result: {'ticket_id': '#${newTicket.ticketId}', 'status': 'Assigned', 'sla': '${newTicket.department.slaHours}h'},
            latency: const Duration(milliseconds: 490),
          ),
        ],
      );

      final updated = List<ChatMessage>.from(state.messages)..add(botMsg);
      emit(state.copyWith(messages: updated, isProcessing: false, stepLabel: ''));
    }
  }
}
