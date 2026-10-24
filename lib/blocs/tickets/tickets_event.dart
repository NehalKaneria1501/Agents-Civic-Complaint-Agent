import 'package:equatable/equatable.dart';
import '../../models/civic_models.dart';

// ==========================================
// BLOC EVENTS: TICKETS
// ==========================================

abstract class TicketsEvent extends Equatable {
  const TicketsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTicketsEvent extends TicketsEvent {
  const LoadTicketsEvent();
}

class AddTicketEvent extends TicketsEvent {
  final CivicTicket ticket;
  const AddTicketEvent(this.ticket);

  @override
  List<Object?> get props => [ticket.ticketId, ticket.status];
}

class AdvanceTicketStatusEvent extends TicketsEvent {
  final CivicTicket ticket;
  const AdvanceTicketStatusEvent(this.ticket);

  @override
  List<Object?> get props => [ticket.ticketId, ticket.status];
}

class EscalateTicketEvent extends TicketsEvent {
  final CivicTicket ticket;
  const EscalateTicketEvent(this.ticket);

  @override
  List<Object?> get props => [ticket.ticketId, ticket.isEscalated];
}

class FilterTicketsEvent extends TicketsEvent {
  final String statusFilter; // 'All', 'Registered', 'Assigned', 'In Progress', 'Resolved'
  const FilterTicketsEvent(this.statusFilter);

  @override
  List<Object?> get props => [statusFilter];
}
